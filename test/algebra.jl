using Symbolics, Test
import Symbolics: isnegated, isdenominator

@sym x y z t

@testset "Construction of SymExprs" begin
    @test x(t) == SymExpr(x, [t])
    @test SymExpr(Sym(:+), [1, 2, 2]) != SymExpr(Sym(:+), [1, 1, 2])
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

@testset "        Helper functions" begin
    @test !isnegated(x)
    @test !isnegated(5)
    @test isnegated(-5)
    @test isnegated(-x)
    @test isnegated(-sin(x))

    @test !isdenominator(5)
    @test !isdenominator(x)
    @test isdenominator(1/x)

    @test numerator(x) == x
    @test denominator(x) == 1

    @test numerator(1/x) == 1
    @test denominator(1/x) == x

    @test numerator(y*z/x) == y*z
    @test denominator(y*z/x) == x

    @test numerator(x/(y*z)) == x
    @test denominator(x/(y*z)) == y*z

    @test numerator(1/-x) == 1
    @test denominator(1/-x) == -x

    @test numerator(1/sin(x)) == 1
    @test denominator(1/sin(x)) == sin(x)

    @test numerator(1/-sin(x)) == 1
    @test denominator(1/-sin(x)) == -sin(x)

    @test numerator(z/(-y*sin(x))) == z
    @test denominator(z/(-y*sin(x))) == -y*sin(x)
end
