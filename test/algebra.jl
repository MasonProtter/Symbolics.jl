using Symbolics, Test

@sym x y t

@testset "Construction of SymExprs" begin
    @test x(t) == SymExpr(x, [t])
end

@testset "                 Algebra" begin
    @test x^2 + x^2 == 2 * x ^ 2
    @test x^2 - x^2 == 0
    @test (2x + y) - 8x == -6x + y
    @test x^2 * y * x^-1 == x*y
    @test ((2x + 3)^2 + 4(2x + 3)^2) * (2x + 3)^3 ==  (2 * x + 3)^5 * 5
    @test x * x^-4 == x^-3
    @test (x^y)^2/x == x^(y*2 - 1)
    @test 1 \ x == x

end

@testset "        Function Algebra" begin
    f(x) = x^3
    g(x) = x^2
    @test (f + g)(x) == x ^ 3 + x ^ 2
    @test (f * g)(x) == x ^ 3 * x ^ 2
end

@testset "            Replacements" begin
    @test (x^2 + 2x)(x => y) == y^2 + 2y
end
