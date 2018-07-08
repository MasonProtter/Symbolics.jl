#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# Some utility functions
#----------------------------------------------------------------------------
walk(x, inner, outer) = outer(x)
walk(x::SymExpr, inner, outer) = outer(SymExpr(inner(x.op), map(inner, x.args)))
walk(x::Expr, inner, outer) = outer(Expr(x.head, map(inner, x.args)...))
postwalk(f, x) = walk(x, x -> postwalk(f, x), f)

function Base.vcat(ex::SymExpr, args::Array{T,1}) where {T}
    SymExpr(ex.op, vcat(ex.args, args))
end

function trim(ex::SymExpr, index::Int)
    SymExpr(ex.op, ex.args[1:end .!= index])
end

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# The main loop for recursively going through a symbolic expression and simplifying it
#----------------------------------------------------------------------------

simplify(x::Union{Sym, Number}) = x

function simplify(ex::SymExpr)
    out1 = simplify_pass(ex)
    out2 = simplify_pass(out1)
    while (out2 isa SymExpr) && (out1 isa SymExpr) && (out2 != out1)
        out1 = simplify_pass(out2)
        out2 = simplify_pass(out1)
    end
    out2
end

simplify_pass(x::Union{Number, Sym}) = x
function simplify_pass(ex::SymExpr)
    postwalk(apply_algebraic_rules, ex)
end

apply_algebraic_rules(x::Union{Number, Function, Sym}) = x
function apply_algebraic_rules(expr::SymExpr)
    @> expr begin
        distribute_negation
        denest
        collect_numeric_terms
    end
end

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# The simplification functions
#----------------------------------------------------------------------------

function distribute_negation(ex::SymExpr)
    @(Match.match) ex begin
        SymExpr(-, [SymExpr(+, args)]) => (out = SymExpr(+, -args))
        _                              => (out = ex)
    end
    out
end


function denest(ex::SymExpr)
    (ex.op in [+, *]) ? denest_op(ex, ex.op) : ex
end

function denest_op(ex, op)
    for arg in ex.args
        if (arg isa SymExpr) && (arg.op == op)
            ii = find(ex.args .== arg)[1]
            return SymExpr(op, vcat(ex.args[1:end .!= ii], arg.args))
        end
    end
    ex
end

function collect_numeric_terms(ex::SymExpr)
    if (ex.op in [+, *]) && (length(ex.args) > 2)
        is_numeric = isa.(ex.args, Number)
        numbers = ex.args[is_numeric]
        if length(numbers) > 1
            new_arg = ex.op(numbers...)
            SymExpr(ex.op, [new_arg, ex.args[.~(is_numeric)]...])
        else
            ex
        end
    else
        ex
    end
end

