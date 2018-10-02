# tests

# [[file:~/Documents/Julia/scrap.org::*tests][tests:1]]
using Symbolics, Test

@sym x y z m ω t;


@testset "Construction of SymExprs" begin
    @test x(t) == SymExpr(x, [t])
end

@testset "Algebra" begin
    @test x^2 + x^2 == 2 * x ^ 2
    @test x^2 - x^2 == 0
    @test (2x + y) - 8x == -6x + y
    @test x^2 * y * x^-1 == x*y
    @test ((2x + 3)^2 + 4(2x + 3)^2) * (2x + 3)^3 ==  (2 * x + 3)^5 * 5
    @test x * x^-4 == x^-3
    @test (x^y)^2/x == x^(y*2 - 1)
end

@testset "Function Algebra" begin
    f(x) = x^3
    g(x) = x^2
    @test (f + g)(x) == x ^ 3 + x ^ 2
    @test (f * g)(x) == x ^ 3 * x ^ 2
end

@testset "Replacements" begin
    @test (x^2 + 2x)(x => y) == y^2 + 2y
end


@testset "Derivatives" begin
    f(x) = x^3
    g(x) = x^2
    @test D(f+g)(x) |> simplify == 3 * x ^ 2 + 2x
    @test (D^2)(f+g)(x) == 3 * (2x) + 2
    @test (D^3)(f+g)(x) == 6
    @test D(x^2 + y^2 + z^2, x) == 2x
    @test D(D(2x*y, x), y) == 2
end

@testset "Euler-Lagrange Solver" begin
    function Γ(w)
       t -> UpTuple((t, w(t), D(w)(t)))
    end

    function Lagrange_Equations(L)
        w -> D(∂(3)(L)∘Γ(w)) - ∂(2)(L)∘Γ(w)
    end

    function L_SHO(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        (0.5m)*qdot^2 - (0.5m*ω^2)*q^2
    end

    function L_free(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        (0.5m)*qdot^2
    end

    function L_pendulum(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        m*qdot^2/2+cos(q)
    end

    @test Lagrange_Equations(L_SHO)(x)(t)  == (D(D(x)))(t) * m + (x)(t) * m * ω ^ 2
    @test Lagrange_Equations(L_free)(x)(t) == (D(D(x)))(t) * m
    @test Lagrange_Equations(L_pendulum)(x)(t) == (D(D(x)))(t) * m + sin((x)(t))
end
# tests:1 ends here
