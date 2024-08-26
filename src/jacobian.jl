Enzyme.API.runtimeActivity!(true)

"""
    jacobian_enzyme_forward_closure(semi::SemidiscretizationHyperbolic; N = pick_batchsize(semi))

Same as `jacobian_enzyme_forward` but with closure

# Notes
I resolved issues related to type instability caused by closures, which is a known limitation of Enzyme.

I utilized closures here because they simplify the reuse of memory buffers and temporary variables without the need for explicit storage.
`let` blocks create a new hard scope and optionally introduce new local bindings.
"""
function jacobian_enzyme_forward_closure(semi)
    t0 = zero(real(semi))
    u_ode = compute_coefficients(t0, semi)
    du_ode = similar(u_ode)

    (;mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache) = semi
    dys = zeros(length(du_ode), length(du_ode))
    dy = zero(du_ode)
    dx = zero(u_ode)
    cache_zero=Enzyme.make_zero(cache)

    inner_func(du, u, cache) = let
        mesh = mesh
        equations = equations
        initial_condition = initial_condition
        boundary_conditions = boundary_conditions
        source_terms = source_terms
        solver = solver
        cache = cache
        my_rhs!(du, u, 0.0, mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache)
    end

    for i in 1:length(du_ode)
        dx[i] = 1.0
        Enzyme.autodiff(Forward, inner_func, Duplicated(du_ode, dy), Duplicated(u_ode, dx), Duplicated(cache, cache_zero)) # ok!
        dys[:, i] = dy
        dx[i] = 0.0
    end

    return dys
end

"""
    jacobian_enzyme_reverse_closure(semi::SemidiscretizationHyperbolic)

Same as `jacobian_enzyme_reverse` but with closure

!!! warning
    Enzyme.jl does not play well with Polyester.jl and there are no plans to fix this soon.
"""
function jacobian_enzyme_reverse_closure(semi)
    t0 = zero(real(semi))
    u_ode = compute_coefficients(t0, semi)
    du_ode = similar(u_ode)

    (;mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache) = semi
    dxs = zeros(length(du_ode), length(du_ode))
    dy = zero(du_ode)
    dx = zero(u_ode)
    cache_zero=Enzyme.make_zero(cache)

    inner_func(du, u, cache) = let
        mesh = mesh
        equations = equations
        initial_condition = initial_condition
        boundary_conditions = boundary_conditions
        source_terms = source_terms
        solver = solver
        cache = cache
        my_rhs!(du, u, 0.0, mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache)
    end

    for i in 1:length(du_ode)
        dy[i] = 1.0
        Enzyme.autodiff(Reverse, inner_func, Duplicated(du_ode, dy), Duplicated(u_ode, dx), Duplicated(semi.cache, cache_zero)) # ok!
        # Enzyme.autodiff(Reverse, inner_func, DuplicatedNoNeed, Duplicated(du_ode, dy), Duplicated(u_ode, dx), Duplicated(semi.cache, cache_zero)) # ok!
        dxs[i, :] .= dx
        dy[i] = 0.0
        dx .= 0.0
    end

    return dxs
end

"""
    jacobian_enzyme_forward(semi::SemidiscretizationHyperbolic)

Uses the right-hand side operator of the semidiscretization `semi`
and forward mode automatic differentiation to compute the Jacobian `J`
of the semidiscretization `semi` at state `u0_ode`.

---

    jacobian_enzyme_forward(f!::F, x::AbstractArray; N = pick_batchsize(x)) where F <: Function

Uses the function `f!` and forward mode automatic differentiation to compute the Jacobian `J`

# Examples
```julia-repl
julia> x = -1:0.5:1;
julia> batch_size = 2;
julia> jacobian_enzyme_forward(TrixiEnzyme.upwind!, x, N=batch_size)
5×5 Matrix{Float64}:
 -0.2  -0.0  -0.0  -0.0   0.2
  0.2  -0.2  -0.0  -0.0  -0.0
 -0.0   0.2  -0.2  -0.0  -0.0
 -0.0  -0.0   0.2  -0.2  -0.0
 -0.0  -0.0  -0.0   0.2  -0.2
```
"""
function jacobian_enzyme_forward end


function jacobian_enzyme_forward(f!::F, x::AbstractArray; N = pick_batchsize(x)) where F <: Function
    # if N == length(x)
    if N == 1
        return vector_mode_jacobian_enzyme_forward(f!, x)
    else
        return batch_mode_jacobian_enzyme_forward(f!, x, N)
    end
end

# %%
###############
# vector mode #
###############

function vector_mode_jacobian_enzyme_forward(f!::F, x::AbstractVector) where F <: Function
    u_ode = zeros(length(x))
    du_ode = zeros(length(x))
    numerical_flux= zeros(length(x))

    dy = zeros(size(du_ode))
    dx = zeros(size(u_ode))
    numerical_flux_shadow= zeros(length(x))
    dys = zeros(length(du_ode), length(du_ode))
    velocity = 1.0
    enzyme_f! = @eval($(Symbol("enzyme_"*string(F.instance))))

    @batch for i in 1:length(x)
        dx[i] = 1.0
        # cache is passed to upwind!
        Enzyme.autodiff(Enzyme.Forward, enzyme_f!, Enzyme.Duplicated(du_ode, dy), Enzyme.Duplicated(u_ode, dx), Const(velocity), Enzyme.Duplicated(numerical_flux, numerical_flux_shadow))
        dys[:, i] .= dy
        dx[i] = 0.0
    end
    return dys
end

# %%
###############
# batch mode #
###############

function batch_mode_jacobian_enzyme_forward(f!::F, x::AbstractVector, N) where F <: Function

    u_ode = zeros(length(x))
    du_ode = zeros(length(x))

    xlen = length(x)
    remainder = xlen % N
    lastchunksize = ifelse(remainder == 0, N, remainder)
    lastchunkindex = xlen - lastchunksize + 1
    middlechunks = 2:div(xlen - lastchunksize, N)
    dys = zeros(length(du_ode), length(du_ode))

    dx = Enzyme.onehot(x, 1, N)
    dy = ntuple(_->zeros(size(x)), N)
    flux = zeros(length(x))
    flux_shadows = ntuple(_->zeros(size(x)), N)
    enzyme_f! = @eval($(Symbol("enzyme_"*string(F.instance))))
    autodiff(Forward, enzyme_f!, BatchDuplicated(du_ode, dy), BatchDuplicated(u_ode, dx), Const(1.0), BatchDuplicatedNoNeed(flux, flux_shadows))

    for j = 1:N
        dys[:, j] .= dy[j]
        dx[j][j] = 0.0
    end

    @batch for c in middlechunks
        i = ((c - 1) * N + 1)
        for j = 1:N
            dx[j][j+i-1] = 1.0
        end
        #copyto!(dys, CartesianIndices((1:size(dys, 1), i:i+N-1)), dy, CartesianIndices(dy))
        Enzyme.autodiff(Forward, enzyme_f!, BatchDuplicated(du_ode, dy), BatchDuplicated(u_ode, dx), Const(1.0), BatchDuplicatedNoNeed(flux, flux_shadows))
        for j = 1:N
            dys[:, i+j-1] .= dy[j]
            dx[j][j+i-1] = 0.0
        end
    end

    dx = ntuple(_->zeros(size(du_ode)), lastchunksize)
    dy = ntuple(_->zeros(size(du_ode)), lastchunksize)
    flux_shadows = ntuple(_->zeros(size(du_ode)), lastchunksize)
    for j = 1:lastchunksize
        dx[j][j+lastchunkindex-1] = 1.0
    end
    Enzyme.autodiff(Forward, enzyme_f!, BatchDuplicated(du_ode, dy), BatchDuplicated(u_ode, dx), Const(1.0), BatchDuplicatedNoNeed(flux, flux_shadows))
    for j = 1:lastchunksize
        dys[:, lastchunkindex+j-1] .= dy[j]
    end

    return dys
end

# %%
function jacobian_enzyme_forward(semi::SemidiscretizationHyperbolic; N = pick_batchsize(semi))
    # if N == length(x)
    if N == 1
        return vector_mode_jacobian_enzyme_forward(semi)
    else
        return batch_mode_jacobian_enzyme_forward(semi, N)
    end
end

function vector_mode_jacobian_enzyme_forward(semi::SemidiscretizationHyperbolic)
    t0 = zero(real(semi))
    u_ode = compute_coefficients(t0, semi)
    du_ode = similar(u_ode)

    # dxs = zeros(length(du_ode), length(du_ode))
    dy = zero(du_ode)
    dx = zero(u_ode)
    dys = zeros(length(du_ode), length(du_ode))

    (;mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache) = semi
    (; boundaries, elements, interfaces) = cache

    for i in 1:length(du_ode)
        dx[i] = 1.0
        Enzyme.autodiff(Forward, enzyme_rhs!, Duplicated(du_ode, dy), Duplicated(u_ode, dx), Const(mesh), Const(equations), Const(initial_condition), Const(boundary_conditions), Const(source_terms), Const(solver), Const(boundaries),
        Const(elements._node_coordinates),
        Const(elements.cell_ids),
        Const(elements.node_coordinates),
        Const(elements.inverse_jacobian),
        Const(interfaces._neighbor_ids),
        Const(interfaces.neighbor_ids),
        Const(interfaces.orientations),
        Duplicated(elements.surface_flux_values, make_zero(elements.surface_flux_values)),
        Duplicated(interfaces.u, make_zero(interfaces.u)))
        dys[:, i] = dy
        dx[i] = 0.0
    end
    return dys
end


function batch_mode_jacobian_enzyme_forward(semi;
        N = min(length(compute_coefficients(zero(real(semi)), semi)), 11))

    t0 = zero(real(semi))
    u_ode = compute_coefficients(t0, semi)
    du_ode = similar(u_ode)

    xlen = length(du_ode)
    remainder = xlen % N
    lastchunksize = ifelse(remainder == 0, N, remainder)
    lastchunkindex = xlen - lastchunksize + 1
    middlechunks = 2:div(xlen - lastchunksize, N)

    (;mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache) = semi
    (; boundaries, elements, interfaces) = cache

    dx = Enzyme.onehot(u_ode, 1, N)
    dy = ntuple(_->zeros(size(u_ode)), N)
    dsurface_flux_values = ntuple(_->similar(elements.surface_flux_values), N)
    dinterfaces_u  = ntuple(_->similar(interfaces.u), N)
    dys = zeros(length(du_ode), length(du_ode))

    Enzyme.autodiff(Forward, my_rhs!, BatchDuplicated(du_ode, dy), BatchDuplicated(u_ode, dx), Const(mesh), Const(equations), Const(initial_condition), Const(boundary_conditions), Const(source_terms), Const(solver), Const(boundaries),
    Const(elements._node_coordinates),
    Const(elements.cell_ids),
    Const(elements.node_coordinates),
    Const(elements.inverse_jacobian),
    Const(interfaces._neighbor_ids),
    Const(interfaces.neighbor_ids),
    Const(interfaces.orientations),
    BatchDuplicatedNoNeed(elements.surface_flux_values, dsurface_flux_values),
    BatchDuplicatedNoNeed(interfaces.u, dinterfaces_u))

    for j = 1:N
        dys[:, j] .= dy[j]
        dx[j][j] = 0.0
    end

    @batch for c in middlechunks
        i = ((c - 1) * N + 1)
        for j = 1:N
            dx[j][j+i-1] = 1.0
        end
        #copyto!(dys, CartesianIndices((1:size(dys, 1), i:i+N-1)), dy, CartesianIndices(dy))
        Enzyme.autodiff(Forward, my_rhs!, BatchDuplicated(du_ode, dy), BatchDuplicated(u_ode, dx), Const(mesh), Const(equations), Const(initial_condition), Const(boundary_conditions), Const(source_terms), Const(solver), Const(boundaries),
        Const(elements._node_coordinates),
        Const(elements.cell_ids),
        Const(elements.node_coordinates),
        Const(elements.inverse_jacobian),
        Const(interfaces._neighbor_ids),
        Const(interfaces.neighbor_ids),
        Const(interfaces.orientations),
        BatchDuplicatedNoNeed(elements.surface_flux_values, dsurface_flux_values),
        BatchDuplicatedNoNeed(interfaces.u, dinterfaces_u))
        for j = 1:N
            dys[:, i+j-1] .= dy[j]
            dx[j][j+i-1] = 0.0
        end
    end

    dx = ntuple(_->zeros(size(du_ode)), lastchunksize)
    dy = ntuple(_->zeros(size(du_ode)), lastchunksize)
    dsurface_flux_values = ntuple(_->similar(elements.surface_flux_values), lastchunksize)
    dinterfaces_u  = ntuple(_->similar(interfaces.u), lastchunksize)

    for j = 1:lastchunksize
        dx[j][j+lastchunkindex-1] = 1.0
    end
    Enzyme.autodiff(Forward, my_rhs!, BatchDuplicated(du_ode, dy), BatchDuplicated(u_ode, dx), Const(mesh), Const(equations), Const(initial_condition), Const(boundary_conditions), Const(source_terms), Const(solver), Const(boundaries),
    Const(elements._node_coordinates),
    Const(elements.cell_ids),
    Const(elements.node_coordinates),
    Const(elements.inverse_jacobian),
    Const(interfaces._neighbor_ids),
    Const(interfaces.neighbor_ids),
    Const(interfaces.orientations),
    BatchDuplicatedNoNeed(elements.surface_flux_values, dsurface_flux_values),
    BatchDuplicatedNoNeed(interfaces.u, dinterfaces_u))
    for j = 1:lastchunksize
        dys[:, lastchunkindex+j-1] .= dy[j]
    end

    return dys
end

# %%

"""
    jacobian_enzyme_reverse(semi::SemidiscretizationHyperbolic)

!!! warning
    Enzyme.jl does not play well with Polyester.jl and there are no plans to fix this soon.
"""
function jacobian_enzyme_reverse(semi)
    t0 = zero(real(semi))
    u_ode = compute_coefficients(t0, semi)
    du_ode = similar(u_ode)

    # dxs = zeros(length(du_ode), length(du_ode))
    dy = zero(du_ode)
    dx = zero(u_ode)
    dxs = zeros(length(du_ode), length(du_ode))

    (;mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache) = semi
    (; boundaries, elements, interfaces) = cache

    for i in 1:length(du_ode)
        dy[i] = 1.0
        Enzyme.autodiff(Reverse, my_rhs!, Duplicated(du_ode, dy), Duplicated(u_ode, dx), Const(mesh), Const(equations), Const(initial_condition), Const(boundary_conditions), Const(source_terms), Const(solver), Const(boundaries),
        Const(elements._node_coordinates),
        Const(elements.cell_ids),
        Const(elements.node_coordinates),
        Const(elements.inverse_jacobian),
        Const(interfaces._neighbor_ids),
        Const(interfaces.neighbor_ids),
        Const(interfaces.orientations),
        Duplicated(elements.surface_flux_values, Enzyme.make_zero(elements.surface_flux_values)),
        Duplicated(interfaces.u, Enzyme.make_zero(interfaces.u)))
        dxs[i, :] .= dx
        dy[i] = 0.0
        dx .= 0.0
    end

    return dxs
end
