var documenterSearchIndex = {"docs":
[{"location":"notes.html#Proof-of-reverse-mode-AD","page":"Notes","title":"Proof of reverse mode AD","text":"","category":"section"},{"location":"notes.html","page":"Notes","title":"Notes","text":"Take the example of polar coordinate system x = r cos theta y = r sin theta, according to the chain rule: (Image: compute_graph) We use t to represent the n-th layer in the tree. with the values of 1,2,3.","category":"page"},{"location":"notes.html","page":"Notes","title":"Notes","text":"fracpartial y_1partial x_1 = fracpartial y_1partial v_4 fracpartial v_4partial x_1 implies fracpartial y_1partial x_1 = sum_i(t) fracpartial y_1partial v_ti colorredfracpartial v_tipartial x_1","category":"page"},{"location":"notes.html","page":"Notes","title":"Notes","text":"fracpartial v_4partial x_1 = fracpartial v_4partial v_-1 fracpartial v_-1partial x_1 + fracpartial v_4partial v_1 fracpartial v_1partial x_1 implies colorredfracpartial v_tipartial x_1 = sum_j(t) fracpartial v_tipartial v_t-1 j fracpartial v_t-1 jpartial x_1","category":"page"},{"location":"notes.html","page":"Notes","title":"Notes","text":"fracpartial y_1partial x_1 = sum_i(t) fracpartial y_1partial v_ti\nsum_j(i) fracpartial v_tipartial v_t-1j fracpartial v_t-1jpartial x_1 = sum_j barv_t-1j fracpartial v_t-1jpartial x_1","category":"page"},{"location":"notes.html","page":"Notes","title":"Notes","text":"where we define adjoint as","category":"page"},{"location":"notes.html","page":"Notes","title":"Notes","text":"barv_t-1 j = sum_i barv_t i fracpartial v_tipartial v_t-1j","category":"page"},{"location":"notes.html","page":"Notes","title":"Notes","text":"For example (in this computing graph):","category":"page"},{"location":"notes.html","page":"Notes","title":"Notes","text":"barv_0 = barv_12 = fracpartial v_21partial v_12 barv_21 + fracpartial v_22partial v_12 barv_22","category":"page"},{"location":"api.html#The-TrixiEnzyme-Module","page":"API reference","title":"The TrixiEnzyme Module","text":"","category":"section"},{"location":"api.html","page":"API reference","title":"API reference","text":"TrixiEnzyme","category":"page"},{"location":"api.html#TrixiEnzyme","page":"API reference","title":"TrixiEnzyme","text":"TrixiEnzyme\n\nTrixiEnzyme.jl is a component package of the Trixi.jl ecosystem and integrates Trixi.jl with Compiler-Based (LLVM level) automatic differentiation via Enzyme.jl for hyperbolic partial differential equations (PDEs). The integration of Trixi.jl with Compiler-Based (LLVM level) automatic differentiation via Enzyme.jl offers the following benefits: facilitates rapid forward mode AD, enables reverse mode AD, supports cross-language AD, and critically, supports mutating operations and caching, on which Trixi.jl relies, to enhance the performance of both simulation runs and AD. The final deliverable will include as many of Trixi's advanced features as possible, such as adaptive mesh refinement, shock capturing, etc., showcasing the benefits of differentiable programming in Julia's ecosystem.\n\n\n\n\n\n","category":"module"},{"location":"api.html#Module-Index","page":"API reference","title":"Module Index","text":"","category":"section"},{"location":"api.html","page":"API reference","title":"API reference","text":"Modules = [TrixiEnzyme]\nOrder   = [:constant, :type, :function, :macro]","category":"page"},{"location":"api.html#Detailed-API","page":"API reference","title":"Detailed API","text":"","category":"section"},{"location":"api.html","page":"API reference","title":"API reference","text":"Modules = [TrixiEnzyme]\nOrder   = [:constant, :type, :function, :macro]","category":"page"},{"location":"api.html#TrixiEnzyme.enzyme_rhs!-Tuple{AbstractVector, AbstractVector, Vararg{Any, 16}}","page":"API reference","title":"TrixiEnzyme.enzyme_rhs!","text":"enzyme_rhs!(du_ode::AbstractVector, u_ode::AbstractVector, mesh, equations, initial_condition, boundary_conditions, source_terms, solver, boundaries, _node_coordinates, cell_ids, node_coordinates, inverse_jacobian, _neighbor_ids, neighbor_ids, orientation, surface_flux_values, u)\n\nThe best thing to do for a user would be to separate out the things that you need to track through, make them arguments to the function, and then simply Duplicate on those.\n\n\n\n\n\n","category":"method"},{"location":"api.html#TrixiEnzyme.jacobian_enzyme_forward","page":"API reference","title":"TrixiEnzyme.jacobian_enzyme_forward","text":"jacobian_enzyme_forward(semi::SemidiscretizationHyperbolic)\n\nUses the right-hand side operator of the semidiscretization semi and forward mode automatic differentiation to compute the Jacobian J of the semidiscretization semi at state u0_ode.\n\n\n\njacobian_enzyme_forward(f!::F, x::AbstractArray; N = pick_batchsize(x)) where F <: Function\n\nUses the function f! and forward mode automatic differentiation to compute the Jacobian J\n\nExamples\n\njulia> x = -1:0.5:1;\njulia> batch_size = 2;\njulia> jacobian_enzyme_forward(TrixiEnzyme.upwind!, x, N=batch_size)\n5×5 Matrix{Float64}:\n -0.2  -0.0  -0.0  -0.0   0.2\n  0.2  -0.2  -0.0  -0.0  -0.0\n -0.0   0.2  -0.2  -0.0  -0.0\n -0.0  -0.0   0.2  -0.2  -0.0\n -0.0  -0.0  -0.0   0.2  -0.2\n\n\n\n\n\n","category":"function"},{"location":"api.html#TrixiEnzyme.jacobian_enzyme_forward_closure-Tuple{Any}","page":"API reference","title":"TrixiEnzyme.jacobian_enzyme_forward_closure","text":"jacobian_enzyme_forward_closure(semi::SemidiscretizationHyperbolic; N = pick_batchsize(semi))\n\nSame as jacobian_enzyme_forward but with closure\n\nNotes\n\nI resolved issues related to type instability caused by closures, which is a known limitation of Enzyme.\n\nI utilized closures here because they simplify the reuse of memory buffers and temporary variables without the need for explicit storage. let blocks create a new hard scope and optionally introduce new local bindings.\n\n\n\n\n\n","category":"method"},{"location":"api.html#TrixiEnzyme.jacobian_enzyme_reverse_closure-Tuple{Any}","page":"API reference","title":"TrixiEnzyme.jacobian_enzyme_reverse_closure","text":"jacobian_enzyme_reverse_closure(semi::SemidiscretizationHyperbolic)\n\nSame as jacobian_enzyme_reverse but with closure\n\nwarning: Warning\nEnzyme.jl does not play well with Polyester.jl and there are no plans to fix this soon.\n\n\n\n\n\n","category":"method"},{"location":"api.html#TrixiEnzyme.pick_batchsize","page":"API reference","title":"TrixiEnzyme.pick_batchsize","text":"pick_batchsize(x)\npick_batchsize(semi)\n\nReturn a reasonable batch size for batched differentiation.\n\nArguments\n\nx: AbstractArray\nsemi: SemidiscretizationHyperbolic in Trixi.jl\n\nNotes\n\nInspired by https://github.com/EnzymeAD/Enzyme.jl/pull/1545/files\n\nwarning: Warning\nThis function is experimental, and not part of the public API.\n\nExamples\n\njulia> pick_batchsize(rand(3))\n3\n\njulia> pick_batchsize(rand(20))\n11\n\n\n\n\n\n","category":"function"},{"location":"api.html#TrixiEnzyme.upwind!-Tuple{Vector, Vector, Any}","page":"API reference","title":"TrixiEnzyme.upwind!","text":"upwind!(du, u, cache)\n\nVanilla upwind scheme\n\n\n\n\n\n","category":"method"},{"location":"examples.html#Examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples.html#Scalar-linear-advection-equation-in-1D","page":"Examples","title":"Scalar linear advection equation in 1D","text":"","category":"section"},{"location":"examples.html","page":"Examples","title":"Examples","text":"We will implement the scalar linear advection equation in 1D with the advection velocity 1 and compute its Jacobian.","category":"page"},{"location":"examples.html","page":"Examples","title":"Examples","text":"using Trixi\nusing TrixiEnzyme\n\n# %%\n# equation with a advection_velocity of `1`.\nadvection_velocity = 1.0\nequations = LinearScalarAdvectionEquation1D(advection_velocity)\n\n# create DG solver with flux lax friedrichs and LGL basis\nsolver = DGSEM(polydeg=3, surface_flux=flux_lax_friedrichs)\n\n# distretize domain with `TreeMesh`\ncoordinates_min = -1.0 # minimum coordinate\ncoordinates_max = 1.0 # maximum coordinate\nmesh = TreeMesh(coordinates_min, coordinates_max,\n                initial_refinement_level=4, # number of elements = 2^4\n                n_cells_max=30_000)\n\n# create initial condition and semidiscretization\ninitial_condition_sine_wave(x, t, equations) = SVector(1.0 + 0.5 * sin(pi * sum(x - equations.advection_velocity * t)))\n\nsemi = SemidiscretizationHyperbolic(mesh, equations, initial_condition_sine_wave, solver)\n\nJ1 = jacobian_ad_forward(semi)\nJ2 = jacobian_enzyme_forward(semi;N=1)\nJ3 = jacobian_enzyme_reverse(semi;N=1)\n\nJ1 == J2","category":"page"},{"location":"GSoC.html#Final-Report:-GSoC-'24","page":"GSoC","title":"Final Report: GSoC '24","text":"","category":"section"},{"location":"GSoC.html","page":"GSoC","title":"GSoC","text":"Student Name: Junyi(@junyixu).\nOrganization: Trixi Framework community.\nMentors: Michael(@sloede) and Hendrik(@ranocha)\nProject: Integrating the Modern CFD Package Trixi.jl with Compiler-Based Auto-Diff via Enzyme.jl\nProject Link: https://github.com/junyixu/TrixiEnzyme.jl","category":"page"},{"location":"GSoC.html#Project-Overview","page":"GSoC","title":"Project Overview","text":"","category":"section"},{"location":"GSoC.html","page":"GSoC","title":"GSoC","text":"Trixi.jl is a numerical simulation framework for conservation laws written in Julia. The integration of Trixi.jl with Compiler-Based (LLVM level) automatic differentiation via Enzyme.jl offers the following benefits: facilitates rapid forward mode AD, enables reverse mode AD, supports cross-language AD, and critically, supports mutating operations and caching, on which Trixi.jl relies, to enhance the performance of both simulation runs and AD. The final deliverable will include as many of Trixi's advanced features as possible, such as adaptive mesh refinement, shock capturing, etc., showcasing the benefits of differentiable programming in Julia's ecosystem.","category":"page"},{"location":"GSoC.html","page":"GSoC","title":"GSoC","text":"Forward Mode Automatic Differentiation (AD) for Discontinuous Galerkin Collocation Spectral Element Method (DGSEM): Implement forward mode automatic differentiation to enhance the calculation of derivatives in DG methods, improving computational efficiency and accuracy for various applications.\nReverse Mode Automatic Differentiation for DG.\nImprove Performance:\nExtract Parameters Passed to Enzyme: Implement a systematic approach to extract and manage parameters passed to Enzyme, ensuring optimal configuration and efficiency in the execution of AD tasks.\nbatchsize for Jacobians:\nOptimize for Memory Bandwidth: Fine-tune the batch size in Jacobian computations to optimize the use of memory bandwidth, thus improving the overall performance and speed of the computations.\nAutomatically Pick batchsize\nExplore Enzyme Custom Rules: Investigate and implement custom rules within the Enzyme AD framework to handle specific cases and operations that are not optimally managed by the default settings, enhancing the flexibility and capability of the AD processes.","category":"page"},{"location":"GSoC.html","page":"GSoC","title":"GSoC","text":"Please note that the last step was planned but remains incomplete due to time constraints and this step will be completed in the future if possible.","category":"page"},{"location":"GSoC.html#Constraints-and-Future-Work","page":"GSoC","title":"Constraints and Future Work","text":"","category":"section"},{"location":"GSoC.html","page":"GSoC","title":"GSoC","text":"Make Reverse Mode AD Work with Polyester.jl: Address compatibility issues and integrate reverse mode AD with Polyester.jl for multithreading capabilities, aiming to enhance performance and scalability of the AD operations across different computing environments.\nIntegrate Enzyme with GPU Kernels: Extend the functionality of Enzyme by integrating it with GPU kernels, allowing AD operations to leverage the parallel processing power of GPUs.","category":"page"},{"location":"GSoC.html#Acknowledgments","page":"GSoC","title":"Acknowledgments","text":"","category":"section"},{"location":"GSoC.html","page":"GSoC","title":"GSoC","text":"The entire project, along with this blog website, is developed and maintained by Junyi(@junyixu). The whole project is under the guidance of two outstanding professors, Michael(@sloede) and Hendrik(@ranocha), from Trixi Framework community.","category":"page"},{"location":"GSoC.html","page":"GSoC","title":"GSoC","text":"The project also received support from other Julia contributors, including Benedict from Trixi Framework community.","category":"page"},{"location":"index.html#TrixiEnzyme","page":"Home","title":"TrixiEnzyme","text":"","category":"section"},{"location":"index.html#Getting-started","page":"Home","title":"Getting started","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"Wikipedia's automatic differentiation entry is a useful resource for learning about the advantages of AD techniques over other common differentiation methods (such as finite differencing).","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"TrixiEnzyme is not a registered Julia package, and it can be installed by running:","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"] add https://github.com/junyixu/TrixiEnzyme.jl.git","category":"page"},{"location":"index.html#Notes-about-Enzyme","page":"Home","title":"Notes about Enzyme","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"Allocations of temporary arrays like these puts more pressure on the GC and impacts performance. That's why we have decided to pre-allocate them in create_cache - which is called when the semidiscretization semi is constructed. This is why we need Enzyme.jl, which supports mutating operations.","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"There's still some caveats  to make_zero! since it's brand new so there's some edge cases on a few structures, but those will get worked out and this flow should be the recommended path. One needs to be careful with a vanilla closure outside Enzyme. If one writes to caches and expect to differentiate through them, then the closure should be duplicated for handling the derivative of those values. If you want to track derivatives through arrays that are enclosed, you have to duplicate the array to have shadow memory for its differentiation. if you want to track derivatives through arrays that are enclosed, you have to duplicate the array to have shadow memory for its differentiation So if you only have the original memory, you cannot do the differentiation since you don't have a place to store the extra values. In a simplified sense, a Dual{Float64} is 128 bits, Float64 is 64 bits, so if you're writing to a buffer of 5 Float64 numbers, you need 5264 bits of space to keep a dual number, which you don't have. So the best thing to do for a user would be to separate out the things that you need to track through, make them arguments to the function, and then simply Duplicate on those. This is how TrixiEnzyme.jacobian_enzyme_forward works: Extract the arguments from semi.cache and duplicate them to store shadows.","category":"page"},{"location":"index.html#Configuring-Batch-Size","page":"Home","title":"Configuring Batch Size","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"To utilize Enzyme.BatchDuplicated(x, ∂f_∂xs) or Enzyme.BatchDuplicatedNoNeed(x, ∂f_∂xs), one can create a tuple containing duals (or shadows). TrixiEnzyme.jl performs partial derivative evaluation on one \"batch\" of the input vector at a time. Each differentiation of a batch requires a call to the target function as well as additional memory proportional to the square of the batch's size. Thus, a smaller batch size makes better use of memory bandwidth at the cost of more calls to the target function, while a larger batch size reduces calls to the target function at the cost of more memory bandwidth.","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"julia> x = -1:0.5:1;\njulia> batch_size = 2\njulia> @time jacobian_enzyme_forward(TrixiEnzyme.upwind!, x, N=batch_size)\n  0.000040 seconds (31 allocations: 1.547 KiB)\n5×5 Matrix{Float64}:\n -0.2  -0.0  -0.0  -0.0   0.2\n  0.2  -0.2  -0.0  -0.0  -0.0\n -0.0   0.2  -0.2  -0.0  -0.0\n -0.0  -0.0   0.2  -0.2  -0.0\n -0.0  -0.0  -0.0   0.2  -0.2\n\njulia> x = -1:0.01:1;\njulia> @time jacobian_enzyme_forward(TrixiEnzyme.upwind!, x, N=2);\n  0.000539 seconds (1.34 k allocations: 390.969 KiB)\njulia> @time jacobian_enzyme_forward(TrixiEnzyme.upwind!, x, N=11);\n  0.000332 seconds (307 allocations: 410.453 KiB)","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"When the cache is relatively small and you have appropriately chosen the batch size, Enzyme generally performs faster than ForwardDiff (see test). (Image: enzyme ForwardDiff upwind)","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"If you do not explicitly provide a batch size, TrixiEnzyme will try to guess one for you based on your input vector:","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"julia> x = -1:0.01:1;\njulia> @time jacobian_enzyme_forward(TrixiEnzyme.upwind!, x);\n  0.000327 seconds (307 allocations: 410.453 KiB)","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"Benchmark for a 401x401 Jacobian of TrixiEnzyme.upwind! (Lower is better): (Image: upwind benchmark) Enyme(@batch) means applying Polyester.@batch to middlebatches.","category":"page"},{"location":"Contact.html#Contact-Developer","page":"Contact Developer","title":"Contact Developer","text":"","category":"section"},{"location":"Contact.html","page":"Contact Developer","title":"Contact Developer","text":"If you have questions, suggestions, or are interested in contributing, feel free to reach out our developer, Junyi, via junyixu0@gmail.com.","category":"page"}]
}
