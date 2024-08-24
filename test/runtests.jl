using Test, TrixiEnzyme

@testset "TrixiEnzyme.jl" begin
    t0 = time()
    @testset "Common" begin
        println("##### Testing Common...")
        t = @elapsed include("CommonTest.jl")
        println("##### done (took $t seconds).")
    end
    println("##### Running all TrixiEnzyme tests took $(time() - t0) seconds.")
end
