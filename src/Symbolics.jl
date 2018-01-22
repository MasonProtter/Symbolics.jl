push!(LOAD_PATH, "/Users/mason/Documents/Julia/Symbolics.jl/src/");
using MacroTools
using Lazy
using Revise
using ForwardDiff

include("types.jl")
include("types.jl")
include("UpDownTuples.jl")
include("Symbolic_Dispatch.jl")
include("Simplification.jl")
include("Sym_Auto_Diff.jl")

# edit("src/Simplification.jl")


@syms x y z

f(x) = x^3

D(f)(x + ϵ)





