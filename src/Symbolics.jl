# [[file:~/Documents/Julia/scrap.org::*Symbolics.jl][Symbolics.jl:1]]
module Symbolics

using LinearAlgebra
using Match
import Lazy: @>
# using ForwardDiff
using DataStructures
using DiffRules


include("types.jl")
# include("UpDownTuples.jl")
include("Utils.jl")
include("SymbolicAlgebra.jl")
include("Simplification.jl")
include("Calculus.jl")
include("FunctionAlgebra.jl")
include("Structure.jl")


export Sym, SymExpr, AbstractSym, AbstractSymExpr, @sym, Symbolic, D, ∂, simplify, UpTuple
export up, down, square

end
# Symbolics.jl:1 ends here
