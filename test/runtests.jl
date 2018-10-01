# [[file:~/Documents/Julia/scrap.org::*tests][tests:1]]
using Symbolics, Test

@sym x y z t;


@testset "Algebra" begin
    @test x^2 + x^2 == 2 * x ^ 2
    @test x^2 - x^2 == 0
    
end

@testset "Fucntion Albegra" begin
    f(x) = x^3
    g(x) = x^2
    @test (f + g)(x) == x ^ 3 + x ^ 2
    @test (f * g)(x) == x ^ 3 * x ^ 2
end

@testset "Derivatives" begin
    @test D(f+g)(x) |> simplify == 3 * x ^ 2 + 2x
    @test (D^2)(f+g)(x) == 3 * (2x) + 2
    @test (D^3)(f+g)(x) == 6

    @test D(x^2 + y^2 + z^2, x) == 2x
    @test D(D(2x*y, x), y) == 2
end


@test x(t) == SymExpr(x, [t])
# tests:1 ends here
