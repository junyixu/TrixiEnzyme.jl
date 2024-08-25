# TrixiEnzyme.jl

[![Build status (Github Actions)](https://github.com/junyixu/TrixiEnzyme.jl/workflows/CI/badge.svg)](https://github.com/junyixu/TrixiEnzyme.jl/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[![dev docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://junyixu.github.io/TrixiEnzyme.jl/dev)

**TrixiEnzyme.jl** is a component package of the [**Trixi.jl**](https://github.com/trixi-framework/Trixi.jl) ecosystem and
integrates Trixi.jl with Compiler-Based (LLVM level) automatic differentiation via [Enzyme.jl](https://github.com/EnzymeAD/Enzyme.jl)
for hyperbolic partial differential equations (PDEs).
This package was initialized through the **Google Summer of Code** program in 2024 and is still under development.

See the [documentation](https://junyixu.github.io/TrixiEnzyme.jl/dev/) for more.

## Installation
To install the package, run the following command in the Julia REPL:
```julia
]  # enter Pkg mode
(@v1.10) pkg> add https://github.com/junyixu/TrixiEnzyme.jl.git
```
Then simply run the following command to use the package:
```julia
using TrixiEnzyme
```

## Current status and TODOs

- [x] General interface development
- [x] Documentation
- [ ] Including more AD Examples/Tutorials
- [ ] GPU compatibility
- [ ] Benchmarking
    - WIP: [ISSUE#3](https://github.com/junyixu/jacobian4DG/issues/3)
