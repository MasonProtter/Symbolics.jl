using Symbolics, Test
import Symbolics: latex

# The number type cannot be defined inside the @testset
struct MySpiffyNumberType{T} <: Symbolic
    a::T
end
struct MyParametricSpiffyNumberType{k,T,U} <: Symbolic
    a::T
    b::U
end
MyParametricSpiffyNumberType{k}(a::T,b::U) where {k,T,U} =
    MyParametricSpiffyNumberType{k,T,U}(a,b)
Base.:(==)(x::MyParametricSpiffyNumberType{k},y::MyParametricSpiffyNumberType{k′}) where {k,k′} = k == k′ && x.a == y.a && x.b == y.b

@testset "Custom number type" begin
    @sym x y z

    @new_number MySpiffyNumberType
    @new_number MyParametricSpiffyNumberType

    Symbolics.latex(n::MySpiffyNumberType{T}) where T =
    "{\\underbrace{\\boxed{\\widetilde{$(n.a)}}}_{\\textrm{$(T)}}}",0

    a = MySpiffyNumberType(45)
    b = MySpiffyNumberType(π)
    c = MyParametricSpiffyNumberType{5}(10, "Hello")
    d = MyParametricSpiffyNumberType{8}(10, "Hello")

    @test a == a
    @test a == MySpiffyNumberType(45)
    @test a != b
    @test c == c
    @test d == d
    @test c != d # For this test to pass, a user-specified :(==) is required

    @test a != x
    @test a + x == x + a
    @test 2(a + x) == 2x + 2a
    @test 3(a + sin(c+b)*d) == (d*sin(b+c) + a)*3

    @testset "LaTeX rendering of custom type" begin
        @test latex(a) == ("{\\underbrace{\\boxed{\\widetilde{45}}}_{\\textrm{$(Int)}}}",0)
        @test latex(b) == ("{\\underbrace{\\boxed{\\widetilde{π = 3.1415926535897...}}}_{\\textrm{Irrational{:π}}}}",0)

        @test latex(a^exp(x + sin(b))) == ("{\\underbrace{\\boxed{\\widetilde{45}}}_{\\textrm{Int64}}}^{\\exp\\left[x+\\sin\\left({\\underbrace{\\boxed{\\widetilde{π = 3.1415926535897...}}}_{\\textrm{Irrational{:π}}}}\\right)\\right]}", 2)
    end
end
