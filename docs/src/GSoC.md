## Pre-GSoC24
- The GSoC proposal: Integrating the Modern CFD Package Trixi.jl with Compiler-Based Auto-Diff via Enzyme.jl (see PDF)
- Implemented AD with pure Julia personally using guidance from a [blog](https://blog.rogerluo.dev/2018/10/23/write-an-ad-in-one-day/)

## GSoC24
- [X] Forward mode AD for DG
- [X] Reverse mode AD for DG
	- [ ] Make reverse mode AD work with Polyester.jl
- [x] Improve performance
	- [x]  Reduce parameters passed to Enzyme
		- [X] Investigating `init_elements` and `init_interfaces`
		- [x] Extract `elements._surface_flux_values` and `cache.interfaces._u`
	- [x] `chunksize` for Jacobians
		- [X] Implemented a [prototype](https://github.com/junyixu/enzyme_MWE/blob/81365fb0ae848bcae592292ca5d9cc82ace53df9/valilla_upwind.jl#L85-L109) for picking the chunk/batch size for the toy model
		- [x] Further optimize for memory bandwidth
- [X] explore Enzyme custom rules

## Future Work
- [ ] Integrate Enzyme with GPU kernels
