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
include("FunctionalDispatch.jl")


export D, ∂, simplification_loop, Sym, @syms, LiteralFunction, UpTuple, SymExpr

end
