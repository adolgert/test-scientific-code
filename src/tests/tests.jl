using Test
using TestSetExtensions
using SafeTestsets

@time @safetestset "greedy coverage" begin include("test_coverage.jl") end
