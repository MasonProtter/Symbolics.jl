# Symbolics.jl

# [[file:~/Documents/Julia/scrap.org::*Symbolics.jl][Symbolics.jl:1]]
module Symbolics

using LinearAlgebra
using Match
using Lazy: @>
using DataStructures
using DiffRules, SpecialFunctions


include("types.jl")
include("Utils.jl")
include("SymbolicAlgebra.jl")
include("Simplification.jl")
include("Calculus.jl")
include("FunctionAlgebra.jl")
include("Structure.jl")
include("NewNumbers.jl")
include("LaTeX.jl")


export Sym, SymExpr, AbstractSym, AbstractSymExpr, @sym, Symbolic, D, ∂, simplify, UpTuple, DownTuple
export up, down, square
export @new_number

end
# Symbolics.jl:1 ends here
