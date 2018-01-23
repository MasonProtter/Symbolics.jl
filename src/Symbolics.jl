module Symbolics

using MacroTools
using Lazy
using Revise
using ForwardDiff

include("types.jl")
include("UpDownTuples.jl")
include("Symbolic_Dispatch.jl")
include("Simplification.jl")
include("Sym_Auto_Diff.jl")

export D, ∂, simplification_loop, Sym, @syms, LiteralFunction, UpTuple

end
