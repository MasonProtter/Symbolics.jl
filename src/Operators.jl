module Operators

export Operator, Dtype, D


abstract type Operator <: Function end

struct Dtype <: Operator end

const D = Dtype()

D(f::Function) = t -> ForwardDiff.derivative(f, t)


end
