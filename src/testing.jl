push!(LOAD_PATH, "/Users/mason/Documents/Julia/Symbolics.jl/src");
using Revise
using Symbolics
# using ForwardDiff

# @edit("Symbolics.jl")
@edit("types.jl")
@edit("Simplification.jl")

@syms x y z;

(2(x^2))^2

ex = (D)(x -> 2x^2 + 4/x^3)(x)  # |> simplification_loop 

ex = 4*((x^2 + 4)*2) |> simplification_loop

Symbolics.unravel_brackets((2*x)*(3 * x ^ 2)).args

Symbolics.postwalk(node -> @show(node), ex)

ex = x^2

ex.args
