push!(LOAD_PATH, "/Users/mason/Documents/Julia/Symbolics.jl/src");
using Revise
using Symbolics
# using ForwardDiff

@edit("Calculus.jl")
@edit("types.jl")
@edit("Simplification.jl")

@syms x y z t m ω;

(2(x^2))^2

ex = (D)(x -> 2x^2 + 4/x^3)(x)  # |> simplification_loop 

ex = 4*((x^2 + 4)*2) |> simplification_loop

Symbolics.unravel_brackets((2*x)*(3 * x ^ 2)).args

Symbolics.postwalk(node -> @show(node), ex)

ex = x^2

ex.args

x^2 + x^2

f(x) = x^3;
g(x) = x^2;
(f+g)(x)
(f*g)(x)

(D^3)(f+g)(x)



x = LiteralFunction(:x)


D(x)(t)
