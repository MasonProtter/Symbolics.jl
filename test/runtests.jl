# tests

# [[file:~/Documents/Julia/scrap.org::*tests][tests:1]]
using Symbolics, DiffRules, SpecialFunctions, Test

@sym x y z m ω t ν μ;


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


@testset "             Derivatives" begin
    f(x) = x^3
    g(x) = x^2
    @test D(f+g)(x) |> simplify == 3 * x ^ 2 + 2x
    @test (D^2)(f+g)(x) == 3 * (2x) + 2
    @test (D^3)(f+g)(x) == 6
    @test D(x^2 + y^2 + z^2, x) == 2x
    @test D(D(2x*y, x), y) == 2
    # test diff rules
    @test D(x -> atan(x,y))(x) ==  y/(x^2 + y^2)
    @test D(y -> atan(x,y))(y) == -x/(x^2 + y^2)
    @test D(x -> hypot(x,y))(x) == x/hypot(x,y)
    @test D(y -> hypot(x,y))(y) == y/hypot(x,y)

    @test D(x -> besselj(ν,x))(x) == (besselj(ν - 1, x) - besselj(ν + 1, x))/2
    @test D(x -> besseli(ν,x))(x) == (besseli(ν - 1, x) + besseli(ν + 1, x))/2
    @test D(x -> bessely(ν,x))(x) == (bessely(ν - 1, x) - bessely(ν + 1, x))/2
    @test D(x -> besselk(ν,x))(x) == (besselk(ν - 1, x) + besselk(ν + 1, x))/2

    @test D(x -> hankelh1(ν,x))(x) == (hankelh1(ν - 1, x) - hankelh1(ν + 1, x))/2
    @test D(x -> hankelh2(ν,x))(x) == (hankelh2(ν - 1, x) - hankelh2(ν + 1, x))/2

    @test D(x -> polygamma(m,x))(x) == polygamma(m + 1, x)

    @test D(x -> beta(x,y))(x) == beta(x,y)*(digamma(x)-digamma(x+y))
    @test D(y -> beta(x,y))(y) == beta(x,y)*(digamma(y)-digamma(x+y))

    @test D(x -> lbeta(x,y))(x) == digamma(x)-digamma(x+y)
    @test D(y -> lbeta(x,y))(y) == digamma(y)-digamma(x+y)

    for (M, f, arity) in DiffRules.diffrules()
        if arity == 1 && (M == :Base || M == :SpecialFunctions) && f ∉ [:inv, :+, :-, :abs, ] # [:bessely0, :besselj0, :bessely1, :besselj1]
            deriv = DiffRules.diffrule(M, f, :x)
            @eval begin
                @test D($M.$f)(x) == $deriv
            end
        end
    end
end

@testset "   UpTuple and DownTuple" begin
    # UpTuple
    ut = UpTuple([x, x^2, -x-y])
    @test ut == ut
    @test string(ut) == "up(x\n   x ^ 2\n   (x + y) * -1)"
    @test (ut(t)).data == [x(t), (x^2)(t), (-x-y)(t)]
    @test string(ut(t)) == string(  UpTuple([x(t), (x^2)(t), (-x-y)(t)])  )
    @test up(ut.data) == ut
    @test ut[2] == x^2
    ut[2] = y
    @test y == ut[2]
    @test ut.data == [x, y, -x-y]
    # DownTuple
    dt = DownTuple([x, x^2, -x-y])
    @test dt == dt
    @test (dt(t)).data == [x(t), (x^2)(t), (-x-y)(t)]
    @test down(dt.data) == dt
end

@testset "   Euler-Lagrange Solver" begin
    function Γ(w)
       t -> UpTuple([t, w(t), D(w)(t)])
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

    function L_free_3d(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        (qdot[1]^2+qdot[2]^2+qdot[3]^2)/2
    end

    q = UpTuple([x, y, z])

    @test Lagrange_Equations(L_free_3d)(q)(t).data == [(D(D(x)))(t), (D(D(y)))(t), (D(D(z)))(t)]

    function L_kepler(local_tuple::UpTuple)
        t, q, qdot = local_tuple.data
        (qdot[1]^2+qdot[2]^2)/2+μ/(q[1]^2+q[2]^2)^(1/2)
    end

    q = UpTuple([x, y])

    # @show Lagrange_Equations(L_kepler)(q)(t).data
    @test Lagrange_Equations(L_kepler)(q)(t).data == SymExpr[(D(D(x)))(t) + ((x)(t) ^ 2 + (y)(t) ^ 2) ^ -1.5 * (x)(t) * μ, (D(D(y)))(t) + ((x)(t) ^ 2 + (y)(t) ^ 2) ^ -1.5 * (y)(t) * μ]

end
# tests:1 ends here
