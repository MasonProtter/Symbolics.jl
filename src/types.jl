using AutoHashEquals

struct Sym
    name::Symbol
end

@auto_hash_equals struct SymExpr
    expr::Union{Expr, SymExpr}
    head::Symbol
    args::Array
end

SymExpr(head::Symbol, args...) = SymExpr(Expr(head, args...))
SymExpr(expr::Expr) = SymExpr(expr, expr.head, expr.args)
SymExpr(expr::SymExpr) = SymExpr(expr.expr, expr.head, expr.args)

function Base.show(io::IO, symexpr::SymExpr)
    print(io, symexpr.expr)
end

Base.eval(a::SymExpr) = eval(a.expr)


Mathy = Union{Number, Sym, SymExpr}
ex = Union{Sym, SymExpr}

function Base.show(io::IO, symbol::Sym)
    print(io, symbol.name)
end


macro syms(names...)
    out = Expr(:block)
    for name in names
        v = Sym(name)
        push!(out.args, Expr(:(=), name, v))
    end
   esc(out)
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
