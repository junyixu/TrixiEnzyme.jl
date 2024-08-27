# Final Report: GSoC '24

- Student Name: Junyi([@junyixu](https://github.com/junyixu)).
- Organization: Trixi Framework community.
- Mentors: Michael([@sloede](https://github.com/sloede)) and Hendrik([@ranocha](https://github.com/ranocha))
- Project: Integrating the Modern CFD Package Trixi.jl with Compiler-Based Auto-Diff via Enzyme.jl
- Project Link: <https://github.com/junyixu/TrixiEnzyme.jl>

## Project Overview
Trixi.jl is a numerical simulation framework for conservation laws written in Julia. The integration of Trixi.jl with Compiler-Based (LLVM level) automatic differentiation via Enzyme.jl offers the following benefits: facilitates rapid forward mode AD, enables reverse mode AD, supports cross-language AD, and critically, supports mutating operations and caching, on which Trixi.jl relies, to enhance the performance of both simulation runs and AD. The final deliverable will include as many of Trixi's advanced features as possible, such as adaptive mesh refinement, shock capturing, etc., showcasing the benefits of differentiable programming in Julia's ecosystem.

- **[Forward Mode](https://junyixu.github.io/TrixiEnzyme.jl/dev/api.html#TrixiEnzyme.jacobian_enzyme_forward) Automatic Differentiation (AD) for Discontinuous Galerkin Collocation Spectral Element Method (DGSEM)**: Implement forward mode automatic differentiation to enhance the calculation of derivatives in DG methods, improving computational efficiency and accuracy for various applications.
- **[Reverse Mode](https://junyixu.github.io/TrixiEnzyme.jl/dev/api.html#TrixiEnzyme.jacobian_enzyme_reverse-Tuple{Any}) Automatic Differentiation for DG**.
- **Improve Performance**:
    - **Extract Parameters Passed to Enzyme**: Implement a systematic approach to extract and manage parameters passed to Enzyme, ensuring optimal configuration and efficiency in the execution of AD tasks.
    - **`batchsize` for Jacobians**:
        - **Optimize for Memory Bandwidth**: Fine-tune the batch size in Jacobian computations to optimize the use of memory bandwidth, thus improving the overall performance and speed of the computations.
        - **Automatically [Pick](https://junyixu.github.io/TrixiEnzyme.jl/dev/api.html#TrixiEnzyme.pick_batchsize) `batchsize`**
- **Explore Enzyme Custom Rules**: Investigate and implement custom rules within the Enzyme AD framework to handle specific cases and operations that are not optimally managed by the default settings, enhancing the flexibility and capability of the AD processes.

Please note that the last step was planned but remains incomplete due to time constraints and this step will be completed in the future if possible.

## Key Highlights

### Function Prototyping

- Functions intended for automatic differentiation with `Enzyme.autodiff` should adhere to specific naming conventions:
    - Functions must start with `enzyme_`.
    - The primary role of these functions is to unpack `semi.cache` and accurately recreate `cache` for effective use with Enzyme’s APIs.

### Configuration

- The functions `jacobian_enzyme_forward` and `jacobian_enzyme_reverse` are configured to behave similarly to `jacobian_ad_forward`, with the primary distinction being how `batchsize` is chosen:
    - An alternative usage pattern involves defining new functions prefixed with `enzyme_` and passing them to `jacobian_enzyme_forward` or `jacobian_enzyme_reverse` for differentiation.

The sole distinction between using reverse mode AD and forward mode AD with `Enzyme.jl` is that you set `dy` as a onehot instead of setting `dx` as a onehot. However, there are some important considerations and potential issues to be aware of:
- In reverse mode, `dx` needs to be [reset](https://github.com/junyixu/jacobian4DG/blob/bf4b60a74a344fc1abbc97c374cec17f7ef23a21/forward_AD_via_enzyme_milestone-06-28/ad_functions.jl#L70) to prevent it from impacting subsequent calculations.
- In reverse mode, mutating functions should `return nothing`; failing to do so can lead to incorrect results from Enzyme.
- In reverse mode, you must initialize intermediate values to zero; if not, Enzyme will yield incorrect outcomes.

### Optimization Strategies

- To enhance performance, several optimization strategies are recommended:
    - Reuse containers for shadow variables during middlebatching and utilize the `@batch` macro for multithreading acceleration to improve computational efficiency.
    - Minimize the number of arguments extracted from `semi.cache` to reduce overhead and streamline computations.
    - Current benchmarks for Enzyme indicate mixed results. In scenarios involving smaller caches, like in toy models, `jacobian_enzyme(semi)` performs better than `ForwardDiff`. However, in the context of Discontinuous Galerkin Collocation Spectral Element Method (DGSEM) simulations, the performance may lag behind `jacobian_ad_forward(semi)` due to the challenges associated with large cache sizes (`elements._surface_flux_values` and `cache.interfaces._u`) and the complexities involved in unpacking and recreating the cache.

This package aims to provide a robust framework for integrating advanced differentiation techniques into Trixi, addressing both performance and usability to facilitate high-quality computational research and development.


## Constraints and Future Work
- **Make Reverse Mode AD Work with Polyester.jl**: Address compatibility issues and integrate reverse mode AD with Polyester.jl for multithreading capabilities, aiming to enhance performance and scalability of the AD operations across different computing environments.
- **Integrate Enzyme with GPU Kernels**: Extend the functionality of Enzyme by integrating it with GPU kernels, allowing AD operations to leverage the parallel processing power of GPUs.

## Acknowledgments

The entire project, along with this website, is developed and maintained by Junyi([@junyixu](https://github.com/junyixu)).
The whole project is under the guidance of two outstanding professors, Michael([@sloede](https://github.com/sloede)) and Hendrik([@ranocha](https://github.com/ranocha)), from Trixi Framework community.

The project also received support from other Julia contributors, including Benedict from Trixi Framework community.
