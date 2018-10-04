# Utils.jl

# [[file:~/Documents/Julia/scrap.org::*Utils.jl][Utils.jl:1]]
walk(x, inner, outer) = outer(x)
walk(x::T, inner, outer) where {T<:AbstractSymExpr} = outer(T(inner(x.op), map(inner, x.args)))
walk(x::Expr, inner, outer) = outer(Expr(x.head, map(inner, x.args)...))
postwalk(f, x) = walk(x, x -> postwalk(f, x), f)

removeiden(ex::AbstractSymExpr) = (ex.op == Sym(:identity)) && (length(ex.args) == 1) ? ex.args[1] : ex
removeiden(x) = x

stripiden(x) = x
stripiden(x::AbstractSymExpr) = postwalk(removeiden, x)

replace_sym(x, p::Pair{AbstractSym, Number}) = x
function replace_sym(ex::Symbolic, p::Pair)
    postwalk(sym -> sym == p.first ? p.second : sym, ex)
end

(ex::SymExpr)(p::Pair) = replace_sym(ex, p)
(ex::Sym)(p::Pair) = replace_sym(ex, p)

Base.promote(::Type{Sym}) = SymExpr
Base.promote(::Type{SymExpr}) = SymExpr

Base.promote(x::T, y::Number) where {T<:Symbolic} = (promote(T)(:identity, [x]), promote(T)(:identity, [y]))
Base.promote(x::Number, y::T) where {T<:Symbolic} = (promote(T)(:identity, [x]), promote(T)(:identity, [y]))
Base.promote(x::Sym, y::SymExpr) = (SymExpr(:identity, [x]), y)
Base.promote(x::SymExpr, y::Sym) = (x, SymExpr(:identity, [y]))

promote_SymForm(x::Number, y::Union{Sym,SymExpr}) = SymExpr
promote_SymForm(x::Union{Sym,SymExpr}, y::Number) = SymExpr
promote_SymForm(x::Union{Sym,SymExpr}, y::Union{Sym,SymExpr}) = SymExpr
# Utils.jl:1 ends here
