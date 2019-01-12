using Symbolics, Test
import Symbolics: latex

# The number type cannot be defined inside the @testset
struct MySpiffyNumberType{T} <: Symbolic
    a::T
end

@testset "Custom number type" begin
    @sym x y z

    # Comparison does not have to include type parameters in the
    # function arguments, they are just here to illustrate that the
    # `@new_number` macro supports this too (i.e. that the comparison
    # can dispatch on type parameters as well).
    @new_number MySpiffyNumberType (a::MySpiffyNumberType{T}, b::MySpiffyNumberType{U}) where {T,U} begin
        a.a == b.a
    end

    Symbolics.latex(n::MySpiffyNumberType{T}) where T =
    "{\\underbrace{\\boxed{\\widetilde{$(n.a)}}}_{\\textrm{$(T)}}}",0

    a = MySpiffyNumberType(45)
    b = MySpiffyNumberType(π)

    @test a == a
    @test a == MySpiffyNumberType(45)
    @test a != b

    @test a != x
    @test a + x == x + a
    @test 2(a + x) == 2x + 2a

    @test latex(a) == ("{\\underbrace{\\boxed{\\widetilde{45}}}_{\\textrm{$(Int)}}}",0)
    @test latex(b) == ("{\\underbrace{\\boxed{\\widetilde{π = 3.1415926535897...}}}_{\\textrm{Irrational{:π}}}}",0)

    @test latex(a^exp(x + sin(b))) == ("{\\underbrace{\\boxed{\\widetilde{45}}}_{\\textrm{Int64}}}^{\\exp\\left[x+\\sin\\left({\\underbrace{\\boxed{\\widetilde{π = 3.1415926535897...}}}_{\\textrm{Irrational{:π}}}}\\right)\\right]}", 2)
end
