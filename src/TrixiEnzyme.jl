"""
    TrixiEnzyme

TrixiEnzyme.jl is a component package of the Trixi.jl ecosystem and integrates Trixi.jl with Compiler-Based (LLVM level) automatic differentiation via Enzyme.jl for hyperbolic partial differential equations (PDEs).
The integration of Trixi.jl with Compiler-Based (LLVM level) automatic differentiation via Enzyme.jl offers the following benefits: facilitates rapid forward mode AD, enables reverse mode AD, supports cross-language AD, and critically, supports mutating operations and caching, on which Trixi.jl relies, to enhance the performance of both simulation runs and AD. The final deliverable will include as many of Trixi's advanced features as possible, such as adaptive mesh refinement, shock capturing, etc., showcasing the benefits of differentiable programming in Julia's ecosystem.
"""
module TrixiEnzyme

export plusTwo, jacobian_enzyme_forward, jacobian_enzyme_forward_closure

using Trixi: AbstractEquations, TreeMesh, DGSEM,
             BoundaryConditionPeriodic, SemidiscretizationHyperbolic,
             VolumeIntegralWeakForm, VolumeIntegralFluxDifferencing,
             wrap_array, compute_coefficients, have_nonconservative_terms,
             boundary_condition_periodic,
             set_log_type, set_sqrt_type
using Enzyme: autodiff, Forward, Reverse, Duplicated, DuplicatedNoNeed, make_zero
using Polyester: @batch

"""
    plusTwo(x)

Sum the numeric "2" to whatever it receives as input

A more detailed explanation can go here, although I guess it is not needed in this case

# Arguments
* `x`: The amount to which we want to add 2

# Notes
* Notes can go here

# Examples
```julia
julia> five = plusTwo(3)
5
```
"""
plusTwo(x) = return x+2

include("prelude.jl")
include("rhs.jl")
include("jacobian.jl")


end # module TrixiEnzyme
