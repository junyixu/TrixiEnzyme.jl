module VanillaUpwindCUDATest
using CUDA
using Enzyme
using Test

"""
CFL number (C = Δt/Δx) as a constant parameter for upwind scheme
"""
const C = 0.2f0

"""
    upwind_kernel!(du, u, v, numerical_flux)

CUDA kernel implementation of the upwind scheme.

# Arguments
- `du`: Output array
- `u`: Input array
- `v`: Advection velocity (constant)
- `numerical_flux`: Array for storing intermediate numerical flux computations

The kernel computes the upwind scheme in two steps:
1. Calculate numerical fluxes for all points
2. Compute spatial derivatives using the fluxes

Each thread handles one grid point in parallel.
"""
function upwind_kernel!(du, u, v, numerical_flux)
    i = threadIdx().x + (blockIdx().x - 1) * blockDim().x

    # Calculate numerical flux
    if i <= length(u)
        numerical_flux[i] = u[i] * v
    end

    # Ensure all threads complete numerical flux calculation
    sync_threads()

    # Compute derivatives
    if i <= length(u)
        if i > 1
            du[i] = -C * (numerical_flux[i] - numerical_flux[i-1])
        else  # i == 1
            du[i] = -C * (numerical_flux[1] - numerical_flux[end])
        end
    end

    return nothing
end

"""
    grad_upwind_kernel!(du, du_shadow, u, u_shadow, v, numerical_flux, numerical_flux_shadow)

Forward-mode automatic differentiation kernel for the upwind scheme.

# Arguments
- `du, du_shadow`: Primal and shadow variables for output
- `u, u_shadow`: Primal and shadow variables for input
- `v`: Advection velocity (constant)
- `numerical_flux, numerical_flux_shadow`: Primal and shadow variables for intermediate flux calculations

Uses Enzyme's forward-mode AD to compute directional derivatives of the upwind scheme.
"""
function grad_upwind_kernel!(du, du_shadow, u, u_shadow, v, numerical_flux, numerical_flux_shadow)
    autodiff_deferred(Forward,
                     Const(upwind_kernel!),
                     Const,
                     Duplicated(du, du_shadow),
                     Duplicated(u, u_shadow),
                     Const(v),
                     Duplicated(numerical_flux, numerical_flux_shadow))
    return nothing
end

"""
    init_first_element_kernel!(arr)

CUDA kernel to initialize the first element of an array to 1.0f0.

# Arguments
- `arr`: Target array to initialize

Only the first thread in the first block performs the initialization to avoid
race conditions. Used for setting initial conditions and AD seeds.
"""
function init_first_element_kernel!(arr)
    if threadIdx().x == 1 && blockIdx().x == 1
        arr[1] = 1.0f0
    end
    return nothing
end

"""
    test_cuda_upwind()

Test function for the CUDA implementation of forward-mode AD upwind scheme.

# Returns
- Array containing the shadow (derivative) values transferred back to CPU

Sets up the problem with:
- Grid size of 201 points
- Initial condition of 1.0 at first point
- Forward-mode seed of 1.0 for the first variable
- Constant advection velocity v = 1.0

The function allocates necessary GPU memory, initializes arrays, runs the AD kernel,
and returns the results for verification.
"""
function test_cuda_upwind()
    # Initialize test data
    n = 201  # number of points
    nthreads = 256
    nblocks = ceil(Int, n/nthreads)

    # Allocate GPU memory
    u = CUDA.zeros(Float32, n)
    du = CUDA.zeros(Float32, n)
    numerical_flux = CUDA.zeros(Float32, n)

    # Set initial condition using kernel
    @cuda threads=1 blocks=1 init_first_element_kernel!(u)

    # Shadow variables for forward mode
    u_shadow = CUDA.zeros(Float32, n)
    du_shadow = CUDA.zeros(Float32, n)
    numerical_flux_shadow = CUDA.zeros(Float32, n)

    # Set forward mode seed using kernel
    @cuda threads=1 blocks=1 init_first_element_kernel!(u_shadow)

    # Constants
    v = 1.0f0

    # Run main kernel
    @cuda threads=nthreads blocks=nblocks grad_upwind_kernel!(
        du, du_shadow, u, u_shadow, v, numerical_flux, numerical_flux_shadow)

    # Synchronize and return results
    CUDA.synchronize()

    return Array(du_shadow)  # Transfer back to CPU for verification
end

# Test suite
@testset "CUDA Upwind Forward Mode" begin
    result = test_cuda_upwind()
    @test length(result) == 201
    # Add more specific test assertions here
end
end
