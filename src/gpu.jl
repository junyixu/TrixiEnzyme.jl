using CUDA
"""
Reverse mode automatic differentiation for GPU version of rhs!

# Arguments
- `semi::SemidiscretizationHyperbolic`: The semidiscretization object containing mesh, equations, etc.

# Returns
- `dxs::CuMatrix{Float32}`: The Jacobian matrix computed using reverse mode AD

# Note
This function computes the Jacobian matrix by:
1. Converting all necessary data to GPU arrays
2. Using Enzyme's reverse mode AD on the CUDA kernels
3. Performing column by column differentiation in a loop
"""
function jacobian_enzyme_reverse_gpu(semi::SemidiscretizationHyperbolic)
    t0 = zero(real(semi))
    u_ode = CuArray(compute_coefficients(t0, semi))
    du_ode = similar(u_ode)
    
    # Initialize arrays for AD on GPU
    dy = CUDA.zeros(size(du_ode))
    dx = CUDA.zeros(size(u_ode))
    dxs = CUDA.zeros(Float32, length(du_ode), length(du_ode))

    # Extract components needed for rhs_gpu!
    (; mesh, equations, boundary_conditions, source_terms, solver, cache) = semi

    # Convert cache components to GPU arrays
    cache_gpu = convert_cache_to_gpu(cache)

    # Loop over each column to compute Jacobian
    for i in 1:length(du_ode)
        # Set seed vector for reverse mode
        dy[i] = one(Float32)
        
        # Apply Enzyme's reverse mode AD
        Enzyme.autodiff(Reverse, rhs_gpu!,
            Duplicated(du_ode, dy),
            Duplicated(u_ode, dx),
            Const(semi),
            Const(t0))
        
        # Store results
        dxs[i, :] .= dx

        # Reset for next iteration
        dy[i] = zero(Float32)
        dx .= zero(Float32)
    end

    return dxs
end

"""
Forward mode automatic differentiation for GPU version of rhs!

# Arguments
- `semi::SemidiscretizationHyperbolic`: The semidiscretization object containing mesh, equations, etc.

# Returns
- `dys::CuMatrix{Float32}`: The Jacobian matrix computed using forward mode AD

# Note
This function computes the Jacobian matrix by:
1. Converting all necessary data to GPU arrays
2. Using Enzyme's forward mode AD on the CUDA kernels
3. Performing row by row differentiation in a loop
"""
function vector_mode_jacobian_enzyme_forward_gpu(semi::SemidiscretizationHyperbolic)
    t0 = zero(real(semi))
    u_ode = CuArray(compute_coefficients(t0, semi))
    du_ode = similar(u_ode)
    
    # Initialize arrays for AD on GPU
    dy = CUDA.zeros(size(du_ode))
    dx = CUDA.zeros(size(u_ode))
    dys = CUDA.zeros(Float32, length(du_ode), length(du_ode))

    # Extract components needed for rhs_gpu!
    (; mesh, equations, boundary_conditions, source_terms, solver, cache) = semi

    # Convert cache components to GPU arrays
    cache_gpu = convert_cache_to_gpu(cache)

    # Loop over each row to compute Jacobian
    for i in 1:length(du_ode)
        # Set seed vector for forward mode
        dx[i] = one(Float32)
        
        # Apply Enzyme's forward mode AD
        Enzyme.autodiff(Forward, rhs_gpu!,
            Duplicated(du_ode, dy),
            Duplicated(u_ode, dx),
            Const(semi),
            Const(t0))
        
        # Store results
        dys[:, i] .= dy

        # Reset for next iteration
        dx[i] = zero(Float32)
    end

    return dys
end

"""
Helper function to convert cache data to GPU arrays

# Arguments
- `cache`: The cache object containing boundaries, elements, and interfaces

# Returns
- `cache_gpu`: A new cache object with all arrays converted to CuArrays
"""
function convert_cache_to_gpu(cache)
    (; boundaries, elements, interfaces) = cache
    
    elements_gpu = (
        surface_flux_values = CuArray(elements.surface_flux_values),
        node_coordinates = CuArray(elements.node_coordinates),
        inverse_jacobian = CuArray(elements.inverse_jacobian),
        cell_ids = CuArray(elements.cell_ids)
    )
    
    boundaries_gpu = CuArray(boundaries)
    
    interfaces_gpu = (
        u = CuArray(interfaces.u),
        neighbor_ids = CuArray(interfaces.neighbor_ids),
        orientations = CuArray(interfaces.orientations)
    )
    
    return (
        boundaries = boundaries_gpu,
        elements = elements_gpu,
        interfaces = interfaces_gpu
    )
end


################  Example usage
# semi = SemidiscretizationHyperbolic(...)  # Your semidiscretization
# jac_reverse = jacobian_enzyme_reverse_gpu(semi)
# jac_forward = vector_mode_jacobian_enzyme_forward_gpu(semi)

# # Convert back to CPU if needed
# jac_reverse_cpu = Array(jac_reverse)
# jac_forward_cpu = Array(jac_forward)
