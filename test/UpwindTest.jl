module UpwindTest
using Test
using TrixiEnzyme
using TrixiEnzyme: upwind!
using ForwardDiff

x = -1:0.01:1
batch_size = 11
jacobian_enzyme_forward(TrixiEnzyme.upwind!, x, N=batch_size)

Δt₁ = @elapsed  J1 = jacobian_enzyme_forward(TrixiEnzyme.upwind!, x)

Δt₂ = @elapsed begin
u = zeros(length(x))
du = zeros(length(x))
cfg = ForwardDiff.JacobianConfig(nothing, du, u)
uEltype = eltype(cfg)
nan_uEltype=convert(uEltype, NaN)
numerical_flux=fill(nan_uEltype, length(u))

J2 = ForwardDiff.jacobian(du, u, cfg) do du_ode, u_ode
    upwind!(du_ode, u_ode, (;v=1.0, numerical_flux));
end;

end; # 0.326764 seconds (1.09 M allocations: 75.013 MiB, 7.28% gc time, 99.87% compilation time)

@test J1 == J2

@info "Compare the time consumed by Enzyme.jl Δt and ForwardDiff.jl..."
@info "Enzyme: $Δt₁ seconds | ForwardDiff: $Δt₂ seconds."

end
