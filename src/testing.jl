push!(LOAD_PATH, "/Users/mason/Documents/Julia/Symbolics.jl/src");
using Symbolics


@syms x y z


expr = D(t -> t^3)(x) |> simplification_loop

MacroTools.postwalk((x -> @show x), expr)

typeof(expr.args[3])

Symbolics.postwalk((x -> @show x), expr)
