function upwind!(du::Vector, u::Vector, cache)
    C = 0.2
    cache.numerical_flux .= u .* cache.v
	for i = 2:length(u)
        du[i] = - C * (cache.numerical_flux[i] - cache.numerical_flux[i-1])  # Q_j^{n+1} = Q_j^n - Δt/Δx * ( F_{j+1/2}^n - F_{j-1/2}^n )
	end
    du[1] = - C * (cache.numerical_flux[1] - cache.numerical_flux[end])
    return nothing
end

upwind_inner_func!(du, u) = let
    cache_ = cache
    du_ = du
    u_ = u
    upwind!(du_, u_, cache_)
end

function enzyme_upwind!(du, u, v, flux)
    cache = (;v = v, numerical_flux  = flux)
    upwind!(du, u, cache)
end

# with closure
function enzyme_rhs!(du_ode::AbstractVector, u_ode::AbstractVector, t, mesh, equations, initial_condition, boundary_conditions, source_terms, dg, cache)
    u = Trixi.wrap_array(u_ode, mesh, equations, solver, cache)
    du = Trixi.wrap_array(du_ode, mesh, equations, solver, cache)
    # Trixi.reset_du!(du, dg, cache)
    Trixi.rhs!(du, u, 0.0, mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache)
    return nothing
end

# without closure
function enzyme_rhs!(du_ode::AbstractVector, u_ode::AbstractVector, mesh, equations, initial_condition, boundary_conditions, source_terms, solver, boundaries, _node_coordinates, cell_ids, node_coordinates, inverse_jacobian, _neighbor_ids, neighbor_ids, orientation, surface_flux_values, u)

    elements = Trixi.ElementContainer1D(inverse_jacobian,node_coordinates,surface_flux_values,cell_ids,_node_coordinates,vec(surface_flux_values))
    interfaces = Trixi.InterfaceContainer1D(u, neighbor_ids, orientation, vec(u), _neighbor_ids)

    cache = (; boundaries, elements, interfaces)

    u_wrap = Trixi.wrap_array(u_ode, mesh, equations, solver, cache)
    du_wrap = Trixi.wrap_array(du_ode, mesh, equations, solver, cache)

    Trixi.rhs!(du_wrap, u_wrap, 0.0, mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache)
    return nothing
end
