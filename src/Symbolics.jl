module Symbolics

using MacroTools
using Lazy
# using ForwardDiff
using AutoHashEquals
using DataStructures

include("types.jl")
# include("UpDownTuples.jl")
include("Symbolic_Dispatch.jl")
include("Simplification.jl")
include("Calculus.jl")

@syms x y z

f(x) = x^2
g(x) = y^x

(D^4)(f + g)(x) |> simplification_loop


export D, ∂, simplification_loop, Sym, @syms, LiteralFunction, UpTuple, SymExpr

end
