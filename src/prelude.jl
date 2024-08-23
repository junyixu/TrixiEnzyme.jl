# %%
const CHUNKSIZE = 11

"""
    pick_batchsize(x)
    pick_batchsize(semi)

Return a reasonable batch size for batched differentiation.

# Arguments
* `x`: AbstractArray
* `semi`: SemidiscretizationHyperbolic in Trixi.jl

# Notes
Inspired by https://github.com/EnzymeAD/Enzyme.jl/pull/1545/files

!!! warning
    This function is experimental, and not part of the public API.

# Examples
```julia-repl
julia> pick_batchsize(rand(3))
3

julia> pick_batchsize(rand(20))
11
```
"""
function pick_batchsize end

function pick_batchsize(x::AbstractArray)
    totalsize = length(x)
    return min(totalsize, CHUNKSIZE) # CHUNKSIZE = 11
end

pick_batchsize(semi::SemidiscretizationHyperbolic) = min(length(compute_coefficients(zero(real(semi)), semi)), CHUNKSIZE)
# %%

