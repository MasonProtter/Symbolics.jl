
struct Sym
    name::Symbol
end

Mathy = Union{Number, Sym, Expr}

function Base.show(io::IO, symbol::Sym)
    print(io, symbol.name)
end


macro syms(names...)
    for name in names
        v = Sym(name)
        eval(:($name = $v))
    end
end

abstract type Operator <: Function end

struct LiteralFunction <: Function
    name::Union{Expr, Symbol, Sym}
end
function Base.show(io::IO, f::LiteralFunction)
    print(io, f.name)
end


struct UpTuple
    data
end


struct Dual_Number
    real::Union{Mathy, UpTuple}
    infinitesimal::Union{Mathy, UpTuple}
    tag::Integer
end

function Base.show(io::IO, dual::Dual_Number)
    if (dual.infinitesimal isa Number) && (dual.infinitesimal < 0)
        op = "-"
    else
        op = "+"
    end
    real_string = dual.real == 0 ? "" : "$(dual.real) $op "
    infinitesimal_string = dual.infinitesimal == 0 ? "" :
                           (dual.infinitesimal isa Number)&&(abs(dual.infinitesimal) == 1) ? "ϵ" :
                           (dual.infinitesimal isa Expr) && (dual.infinitesimal.args[1] == :+ || dual.infinitesimal.args[1] == :-) ?
                               "($(dual.infinitesimal))ϵ" :
                               "$(dual.infinitesimal)ϵ"
    print(io, "$real_string$infinitesimal_string")
end


struct Dtype <: Operator end
const D = Dtype()
const ∂ = Dtype()
