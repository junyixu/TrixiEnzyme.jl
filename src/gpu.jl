module ADGPU
using CUDA
using Enzyme
using Trixi
using TrixiCUDA
export grad_rhs_gpu!, compute_gradient_gpu

"""
    grad_rhs_gpu!(du, du_shadow, u, u_shadow, semi)

Compute the gradient of the RHS function using forward-mode AD on GPU.

# Arguments
- `du`: Primal output array on GPU
- `du_shadow`: Shadow (derivative) output array on GPU
- `u`: Primal input array on GPU 
- `u_shadow`: Shadow (derivative) input array on GPU
- `semi`: SemidiscretizationHyperbolic object containing simulation parameters

# Implementation Details
1. Decomposes semi object into base components for GPU computation
2. Uses Enzyme's forward-mode AD to compute directional derivatives
3. Applies AD to each component of the RHS computation pipeline
"""
function grad_rhs_gpu!(du, du_shadow, u, u_shadow, semi)
    # Extract components needed for computation
    mesh = semi.mesh
    equations = semi.equations
    boundary_conditions = semi.boundary_conditions
    source_terms = semi.source_terms
    dg = semi.solver
    cache = semi.cache

    # Compute surface flux values and interface data derivatives
    surface_flux_values = cache.elements.surface_flux_values |> TrixiCUDA.cu
    surface_flux_shadow = CUDA.zeros(size(surface_flux_values))
    
    interface_u = cache.interfaces.u |> TrixiCUDA.cu
    interface_u_shadow = CUDA.zeros(size(interface_u))

    # Set number of threads/blocks for kernel launch
    threads = 256
    blocks = cld(length(u), threads)

    # Initialize first element with seed value
    @cuda threads=1 blocks=1 init_first_element_kernel!(u_shadow)
    
    # Apply forward mode AD to RHS computation
    autodiff_deferred(Forward,
                     Const(rhs_gpu!),
                     Duplicated(du, du_shadow),
                     Duplicated(u, u_shadow),
                     Const(0.0f0),  # time parameter
                     Const(mesh),
                     Const(equations),
                     Const(boundary_conditions),
                     Const(source_terms),
                     Const(dg),
                     Const(cache))
                     
    return nothing
end

"""
    compute_gradient_gpu(semi::SemidiscretizationHyperbolic)

Main function to compute gradient of RHS on GPU.

# Arguments
- `semi`: SemidiscretizationHyperbolic object

# Returns
- `Array{Float32}`: Gradient vector transferred back to CPU

# Implementation
1. Allocates necessary GPU memory
2. Sets up AD computation
3. Runs gradient calculation
4. Transfers results back to CPU
"""
function compute_gradient_gpu(semi::SemidiscretizationHyperbolic)
    # Initialize state vectors on GPU
    u = compute_coefficients(0.0f0, semi) |> TrixiCUDA.cu
    du = CUDA.zeros(Float32, size(u))
    
    # Shadow variables for forward mode
    u_shadow = CUDA.zeros(Float32, size(u))
    du_shadow = CUDA.zeros(Float32, size(du))

    # Compute gradient
    grad_rhs_gpu!(du, du_shadow, u, u_shadow, semi)
    
    # Synchronize and return results
    CUDA.synchronize()
    
    return Array(du_shadow)
end

"""
    init_first_element_kernel!(arr)

CUDA kernel to initialize the first element as the seed for gradient computation.

# Arguments
- `arr`: Target array to initialize with seed value
"""
function init_first_element_kernel!(arr)
    if threadIdx().x == 1 && blockIdx().x == 1
        arr[1] = 1.0f0
    end
    return nothing
end
end
