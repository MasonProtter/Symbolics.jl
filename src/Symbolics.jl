__precompile__()

module Symbolics

using LinearAlgebra
using MacroTools   
import Lazy: @>
# using ForwardDiff
using DataStructures
# using Match


include("types.jl")
# include("UpDownTuples.jl")
include("Utils.jl")
include("SymbolicAlgebra.jl")
include("Simplification.jl")
include("Calculus.jl")
include("FunctionAlgebra.jl")


export Sym, SymExpr, AbstractSym, AbstractSymExpr, @sym, Symbolic, D, ∂, simplify, UpTuple

end
