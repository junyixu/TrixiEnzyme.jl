# TrixiEnzyme

## Getting started

[Wikipedia's automatic differentiation entry](https://en.wikipedia.org/wiki/Automatic_differentiation) is a useful resource for learning about the advantages of AD techniques over other common differentiation methods (such as finite differencing).

TrixiEnzyme is not a registered Julia package, and it can be installed by running:
```
] add https://github.com/junyixu/TrixiEnzyme.jl.git
```

## Configuring Batch Size

TrixiEnzyme.jl performs partial derivative evaluation on one "batch" of the input vector at a time.
Each differentiation of a batch requires a call to the target function as well as additional memory proportional to the square of the batch's size.
Thus, a smaller batch size makes better use of memory bandwidth at the cost of more calls to the target function,
while a larger batch size reduces calls to the target function at the cost of more memory bandwidth.

```julia-repl
julia> x = -1:0.5:1;
julia> batch_size = 2
julia> @time jacobian_enzyme_forward(TrixiEnzyme.upwind!, x, N=batch_size)
  0.000040 seconds (31 allocations: 1.547 KiB)
5×5 Matrix{Float64}:
 -0.2  -0.0  -0.0  -0.0   0.2
  0.2  -0.2  -0.0  -0.0  -0.0
 -0.0   0.2  -0.2  -0.0  -0.0
 -0.0  -0.0   0.2  -0.2  -0.0
 -0.0  -0.0  -0.0   0.2  -0.2

julia> x = -1:0.01:1;
julia> @time jacobian_enzyme_forward(TrixiEnzyme.upwind!, x, N=2);
  0.000539 seconds (1.34 k allocations: 390.969 KiB)
julia> @time jacobian_enzyme_forward(TrixiEnzyme.upwind!, x, N=11);
  0.000332 seconds (307 allocations: 410.453 KiB)
```

If you do not explicitly provide a chunk size, TrixiEnzyme will try to guess one for you based on your input vector:

```julia-repl
julia> x = -1:0.01:1;
julia> @time jacobian_enzyme_forward(TrixiEnzyme.upwind!, x);
  0.000327 seconds (307 allocations: 410.453 KiB)
```
