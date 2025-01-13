function test_cuda_rhs(semi_gpu)
      tspan = (0.0, 1.0)
    tspan_gpu = CuArray([tspan[1], tspan[2]])  # 转换到 GPU

    # 获取组件
    (;mesh, equations, initial_condition, boundary_conditions, source_terms, solver, cache) = semi_gpu

    # 初始化数据
    ode_gpu = semidiscretizeGPU(semi_gpu, tspan_gpu)
    u = copy(ode_gpu.u0)
    du = similar(u)

    # Shadow variables
    u_shadow = similar(u)
    du_shadow = similar(du)
    cache_shadow = make_zero(cache)

    # 只为 forward mode 设置种子
    @cuda threads=1 blocks=1 init_first_element_kernel!(u_shadow)

    # 调用 Enzyme
    Enzyme.autodiff(Forward, enzyme_rhs!,
                   Duplicated(du, du_shadow),
                   Duplicated(u, u_shadow),
                   Duplicated(cache, cache_shadow),
                   Const(mesh),
                   Const(equations),
                   Const(initial_condition),
                   Const(boundary_conditions),
                   Const(source_terms),
                   Const(solver))

    return Array(du_shadow)
end
