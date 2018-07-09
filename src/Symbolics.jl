__precompile__()

module Symbolics

#using MacroTools   
using Lazy
# using ForwardDiff
using AutoHashEquals
using DataStructures
using Match

include("types.jl")
# include("UpDownTuples.jl")
include("Symbolic_Dispatch.jl")
include("Simplification.jl")
include("Calculus.jl")
include("FunctionalDispatch.jl")


export D, ∂, simplify, Sym, @syms, LiteralFunction, UpTuple, SymExpr

end
