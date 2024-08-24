module CommonTest

using Test
using TrixiEnzyme
using TrixiEnzyme:Enzyme
using ForwardDiff

# %%

function foo!(y, x, cache)
    cache .= x.^2
    y .= 2cache
    return nothing
end

function foo!(y, x)
    y .= 2*(x.^2)
    return nothing
end
# %%


x = ones(3)
y = similar(x)
cache = similar(x)

dx = Enzyme.onehot(x)
dy = ntuple(_->zeros(size(x)), length(x))
dcache = ntuple(_->zeros(size(x)), length(x))

dcache1 = similar(x)
dx1 = zero(x)
dx1[1] = 1.0
dy1 = similar(x)

autodiff(Forward, foo!, BatchDuplicated(y, dy), BatchDuplicated(x, dx))
J1 = stack(dy)

autodiff(Forward, foo!, BatchDuplicated(y, dy), BatchDuplicated(x, dx), BatchDuplicatedNoNeed(cache, dcache))
J2 = stack(dy)

autodiff(Forward, foo!, BatchDuplicated(y, dy), BatchDuplicated(x, dx), BatchDuplicated(cache, dcache))
J3 = stack(dy)

autodiff(Forward, foo!, Duplicated(y, dy1), Duplicated(x, dx1), DuplicatedNoNeed(cache, dcache1))


# %%
@info "testing foo!(y, x, cache)"


# cfg = ForwardDiff.JacobianConfig(nothing, y, x, ForwardDiff.Chunk(2))
cfg = ForwardDiff.JacobianConfig(nothing, y, x)
uEltype = eltype(cfg)
nan_uEltype=convert(uEltype, NaN)
cache=fill(nan_uEltype, length(x))

J = ForwardDiff.jacobian(y, x, cfg) do y,x
    foo!(y, x, cache)
end

@test J == J1 == J2 == J3

@test J[:, 1] == dy1

end
