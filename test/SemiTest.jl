module SemiTest
using Test
using TrixiEnzyme
using TrixiEnzyme: LinearScalarAdvectionEquation1D, DGSEM, TreeMesh, SVector, flux_lax_friedrichs, SemidiscretizationHyperbolic

# %%
# equation with a advection_velocity of `1`.
advection_velocity = 1.0
equations = LinearScalarAdvectionEquation1D(advection_velocity)

# create DG solver with flux lax friedrichs and LGL basis
solver = DGSEM(polydeg=3, surface_flux=flux_lax_friedrichs)

# distretize domain with `TreeMesh`
coordinates_min = -1.0 # minimum coordinate
coordinates_max = 1.0 # maximum coordinate
mesh = TreeMesh(coordinates_min, coordinates_max,
                initial_refinement_level=4, # number of elements = 2^4
                n_cells_max=30_000)

# create initial condition and semidiscretization
initial_condition_sine_wave(x, t, equations) = SVector(1.0 + 0.5 * sin(pi * sum(x - equations.advection_velocity * t)))

semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition_sine_wave, solver)
# %%

@info "testing LinearScalarAdvectionEquation1D: jacobian_ad_forward(semi) == jacobian_enzyme_forward(semi)"

@test jacobian_ad_forward(semi) == jacobian_enzyme_forward(semi;N=1)

end
