using Base.Test

@syms x y z

@test x^2 + x^2 == 2 * x ^ 2
@test x^2 - x^2 == 0

let
    f(x) = x^3
    g(x) = x^2
    @test (f + g)(x) == x ^ 3 + x ^ 2
    @test (f * g)(x) == x ^ 3 * x ^ 2
    @test D(f+g)(x) == 3 * x ^ 2 + 2x
    @test (D^2)(f+g)(x) == 3 * (2x) + 2
    @test (D^3)(f+g)(x) == 6
end


@test simplify(x + y + x) == SymExpr(+, [2x, y])
@test simplify(x*y*x) == SymExpr(*, [x^2, y])
@test simplify(x*y*x + x*y*x) == SymExpr(*, [2, x^2, y])
