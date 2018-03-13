push!(LOAD_PATH, "/Users/mason/Documents/Julia/Symbolics.jl/src");
using Symbolics

struct QOp <: Symbolics.Operator end
const X = QOp()
X(ψ) = x -> x*ψ

@syms x y z;

D(D(x -> x^3 - 4x^2))(x)


S = Sx + Sy + Sz


Sx = 1/2 *



ϵ1

X(x -> e^-(x^2))(x)

f = LiteralFunction(:f)
f(x)

D(X(f))(x)


D(x -> f(x)^2 + x)(x)


f(x) = log(x^4)^2
D(f)(x)


-> ExtractDiffPart(f(x + ϵ))
-> ExtractDiffPart((log((x+ϵ)^4))^2)
-> ExtractDiffPart((log(x^4 + 4*x^3*ϵ))^2)
-> ExtractDiffPart((log(x^4) + 4*x^3*ϵ/x^4)^2)
-> ExtractDiffPart((log(x^4))^2 + 2*log(x^4)*4*x^3/x^4*ϵ)
-> 2*log(x^4)*4*x^3/x^4


using HCubature
∫=hquadrature

f(ω,x) = ω*sin(x)^2

F(ω) = ∫(x -> f(ω,x), 0, 2π, maxevals=100)[1]

F(0)

F(1.1)

(x->f(ω, x))(1)



L(q,q̇,t) = m*q̇^2/2
integrateLagrangian(L, )
