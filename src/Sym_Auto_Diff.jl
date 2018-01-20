module Sym_Auto_Diff

import Base.show
import Base.conj
import Base.+
import Base.-
import Base.*
import Base./
import Base.^
import Base.log
import Base.sin
import Base.cos
import Base.dot
import Base.zero

export +, -, *, /, *, ^, log, sin, cos, dot, zero, dual_number, Dual_Number, LiteralFunction, infinitesimal, ϵ, square, conj, D, ∂, up, expand_term

# import Base.



push!(LOAD_PATH, "/Users/mason/Documents/Julia/JuliaMath")
using types
using Symbolic_Dispatch
using Simplification
using Revise
using UpDownTuples
import UpDownTuples.square
import Simplification.expand_term


Mathy = Union{Number, Sym, Expr}


(f::LiteralFunction)(t) = :($(f.name)($t))


infinitesimal(a::Dual_Number) = a.infinitesimal
infinitesimal(a::Dual_Number, tag::Integer) =
infinitesimal(a::UpTuple) = up(infinitesimal(i) for i in a.data)
infinitesimal(a::Union{Number, Sym, Expr}) = 0

tag_counter = 0
function iterate_tag()
    global tag_counter += 1
end

function dual_number(a::Mathy, b::Mathy)
    if b == 0
        a
    else
        Dual_Number(a, b, tag_counter)
    end
end

dual_number(a) = dual_number(0, a)


(f::LiteralFunction)(t::Dual_Number) = begin
    dual_number(:($(f.name)($(t.real))) |> expand_expression,  :(D($(f.name))($(t.real)))|> expand_expression)
end




ϵ = dual_number(0, 1)

conj(a::Dual_Number) = dual_number(a.real, -(a.infinitesimal))

+(a::Dual_Number, b::Dual_Number) = dual_number(a.real + b.real, a.infinitesimal + b.infinitesimal)
+(a::Dual_Number, b::Mathy) = dual_number(a.real + b, a.infinitesimal)
+(a::Mathy, b::Dual_Number) = dual_number(a + b.real, b.infinitesimal)

-(a::Dual_Number, b::Dual_Number) = dual_number(a.real - b.real, a.infinitesimal - b.infinitesimal)
-(a::Dual_Number, b::Mathy) = dual_number(a.real - b, a.infinitesimal)
-(a::Mathy, b::Dual_Number) = dual_number(a - b.real, b.infinitesimal)

*(a::Dual_Number, b::Dual_Number) = dual_number(a.real * b.real, a.infinitesimal * b.real + a.real * b.infinitesimal)
*(a::Dual_Number, b::Mathy) = dual_number(a.real * b, a.infinitesimal * b)
*(a::Mathy, b::Dual_Number) = dual_number(a * b.real, a * b.infinitesimal)
dot(a::Union{Mathy,Dual_Number,LiteralFunction}, b::Union{Mathy,Dual_Number,LiteralFunction}) = a*b
zero(a::Dual_Number) = 0*a
zero(a) = 0
square(a::Dual_Number) = a*a


/(a::Dual_Number, b::Dual_Number) = b.real != 0 ? (a * conj(b))/(b.real)^2 : Inf
/(a::Dual_Number, b::Mathy) = dual_number(a.real / b, a.infinitesimal / b)
/(a::Mathy, b::Dual_Number) = b.real != 0 ? (a * conj(b))/(b.real)^2 : Inf

# ^(a::Dual_Number, b::Dual_Number) = dual_number(a.real^b.real, a.real^b.real * ())
^(a::Dual_Number, b::Mathy) = dual_number(a.real^b, b * a.real^(b-1) * a.infinitesimal)
^(a::Dual_Number, b::Integer) = dual_number(a.real^b, b * a.real^(b-1) * a.infinitesimal)
^(a::Mathy, b::Dual_Number) = dual_number(b^a.real, log(b) * a^b.real * a.infinitesimal)

log(a::Dual_Number) = dual_number(log(a.real), 1/a.real * a.infinitesimal)

sin(a::Dual_Number) = dual_number(sin(a.real), cos(a.real)*a.infinitesimal)
cos(a::Dual_Number) = dual_number(cos(a.real), -sin(a.real)*a.infinitesimal)






function D(f::Function)
    Df(t::Number) = ForwardDiff.derivative(f, t)
    Df(t::ex) = infinitesimal(f(t + ϵ) ) |> expand_expression
    function Df(t::Dual_Number)
        real_part = D(f)(t.real) |> expand_expression
        df = eval(Expr(:function, Expr(:call, gensym(), :t), :($(D(f)(:t)))))
        diff_part = infinitesimal(Base.invokelatest(df, t)) |> expand_expression
        dual_number(real_part, diff_part)
    end
end

D(f::LiteralFunction) = LiteralFunction(:(D($(f.name))))

(D::Dtype)(arr::UpTuple) = up([D(i) for i in arr.data]...)



function ∂(f::Function, index::Integer)
    # function ∂f(arr::UpTuple)
    #     argugment = up([i != index ? arr.data[i] : arr.data[i] + ϵ for i in 1:length(arr.data)]...)
    #     infinitesimal(f(argugment)) |> expand_expression
    # end
    function ∂f(arr::UpTuple)
        function partial_f(t)
            f(up([i != index ? arr.data[i] : t for i in 1:length(arr.data)]...))
        end
        D(partial_f)(arr[index])
    end
end
#
#
# m = Sym(:m)
# k = Sym(:k)
# x = LiteralFunction(Sym(:x))
#
# function L(local_tuple)
#     t, q, qdot = local_tuple
#     1/2*m*square(qdot) + 1/2*k*square(q)
# end
#
# # x = LiteralFunction(:x)
#
# function Γ(w)
#     local_tuple(t) = up(t, w(t), D(w)(t))
# end
#
# function Lagrange_Equations(L)
#     w ->  D((∂(L,3)∘(Γ(w)))) - ∂(L,2)∘Γ(w)
# end
#
#
#
#
# (∂(L,2)∘Γ(x))(:t) |> expand_expression
#
# Simplification.expand_term(m)
#
#
#
#
# D(∂(L,3)∘(Γ(x)))(:t)
#
#
# Lagrange_Equations(L)(x)(:t)



end
