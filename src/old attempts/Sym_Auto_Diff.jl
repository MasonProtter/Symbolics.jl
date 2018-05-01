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



(f::LiteralFunction)(t) = :($(f.name)($t))


infinitesimal(a::Dual_Number) = a.infinitesimal
infinitesimal(a::Dual_Number, tag::Integer) =
infinitesimal(a::UpTuple) = up(infinitesimal(i) for i in a.data)
infinitesimal(a::Union{Number, Sym, SymExpr}) = 0

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
    dual_number(SymExpr(:($(f.name)($(t.real)))) |> expand_expression,  SymExpr(:(D($(f.name))($(t.real))))|> expand_expression)
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
    Df(t::ex) = infinitesimal(f(t + ϵ) ) |> simplification_loop
    function Df(t::Dual_Number)
        real_part = D(f)(t.real) |> simplification_loop
        df = eval(Expr(:function, Expr(:call, gensym(), :t), :($(D(f)(Sym(:t))))))
        diff_part = infinitesimal(Base.invokelatest(df, t)) |> simplification_loop
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
