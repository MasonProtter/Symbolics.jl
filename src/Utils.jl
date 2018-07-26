
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


# function (s)
#     if s isa Sym
#         try
#             eval(s.name) isa Sym ? s(t)
# (f::SymExpr)(t) = length(f.args == 1) ? SymExpr(f.op, [f.args[1](t)]) : throw("whoops, still fucked!")

                                                
# (f::SymExpr)(t) = postwalk(s -> s isa Sym ? (eval(s.name) isa Sym ? s(t) : s) : s, f)
# (f::SymExpr)(args...) = SymExpr(f, [args...])
