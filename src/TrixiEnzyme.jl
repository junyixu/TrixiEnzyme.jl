"""
    TrixiEnzyme

TrixiEnzyme.jl is a component package of the Trixi.jl ecosystem and integrates Trixi.jl with Compiler-Based (LLVM level) automatic differentiation via Enzyme.jl for hyperbolic partial differential equations (PDEs).
The integration of Trixi.jl with Compiler-Based (LLVM level) automatic differentiation via Enzyme.jl offers the following benefits: facilitates rapid forward mode AD, enables reverse mode AD, supports cross-language AD, and critically, supports mutating operations and caching, on which Trixi.jl relies, to enhance the performance of both simulation runs and AD. The final deliverable will include as many of Trixi's advanced features as possible, such as adaptive mesh refinement, shock capturing, etc., showcasing the benefits of differentiable programming in Julia's ecosystem.
"""
module TrixiEnzyme

export plusTwo, jacobian_enzyme_forward, jacobian_enzyme_forward_closure
export autodiff, Forward, Reverse, Duplicated, DuplicatedNoNeed, BatchDuplicated, BatchDuplicatedNoNeed, Const

using Trixi: AbstractEquations, TreeMesh, DGSEM,
             BoundaryConditionPeriodic, SemidiscretizationHyperbolic,
             VolumeIntegralWeakForm, VolumeIntegralFluxDifferencing,
             wrap_array, compute_coefficients, have_nonconservative_terms,
             boundary_condition_periodic,
             set_log_type, set_sqrt_type
import Enzyme
using Enzyme: autodiff, Forward, Reverse, Duplicated, DuplicatedNoNeed, make_zero, BatchDuplicated, BatchDuplicatedNoNeed, Const
using Polyester: @batch

include("prelude.jl")
include("rhs.jl")
include("jacobian.jl")


end # module TrixiEnzyme
