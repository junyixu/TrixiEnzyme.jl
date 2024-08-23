"""
    jacobian_enzyme_forward(semi::SemidiscretizationHyperbolic)

Uses the right-hand side operator of the semidiscretization `semi`
and forward mode automatic differentiation to compute the Jacobian `J`
of the semidiscretization `semi` at state `u0_ode`.
"""
function jacobian_enzyme_forward(semi)
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
        Enzyme.autodiff(Forward, my_rhs!, Duplicated(du_ode, dy), Duplicated(u_ode, dx), Const(mesh), Const(equations), Const(initial_condition), Const(boundary_conditions), Const(source_terms), Const(solver), Const(boundaries),
        Const(elements._node_coordinates),
        Const(elements.cell_ids),
        Const(elements.node_coordinates),
        Const(elements.inverse_jacobian),
        Const(interfaces._neighbor_ids),
        Const(interfaces.neighbor_ids),
        Const(interfaces.orientations),
        Duplicated(elements.surface_flux_values, Enzyme.make_zero(elements.surface_flux_values)),
        Duplicated(interfaces.u, Enzyme.make_zero(interfaces.u)))
        dys[:, i] = dy
        dx[i] = 0.0
    end
    return dys
end
