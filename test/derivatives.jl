using Symbolics, Test, DiffRules, SpecialFunctions

@sym x y z m ν

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
