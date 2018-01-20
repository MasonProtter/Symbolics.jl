module Derivatives

export D, ∂, Operator, Dtype

push!(LOAD_PATH, "/Users/mason/Documents/Julia/JuliaMath")
using Simplification
using MacroTools

ex = Union{Symbol, Expr}

abstract type Operator <: Function end

struct Literal_Function <: Function end
const literal_function = Literal_Function()

function literal_function(name::ex)
    function (t::ex)
        :($name($t))
    end
end


struct Dtype <: Operator end
const D = Dtype()
const ∂ = Dtype()

function D(f::Function)
    function out(t::Number)
        ForwardDiff.derivative(f, t)
    end
    function out(t::ex)
        MacroTools.postwalk(x -> x == :t? t : x, :(D($(f(:t)))) |> expansion_loop)
    end
    out
end

function D(f::Literal_Function)
    function (t::ex)
        :(D($f)($t))
    end
end




function ∂1(f::Function)
     function (t, q, qdot)

     end
end





end
