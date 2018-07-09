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

function find_first_duplicates(a::Array)
    for i in 1:(length(a)-1)
        out = [i]
        for j in (i+1):length(a)
            if a[i] == a[j]
                push!(out, j)
            end
            if (j == length(a)) && (length(out) > 1)
                return out
            end
        end
    end
    []
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
        collect_identical
        mult_zero
        remove_identity_operations
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


function collect_identical(ex::SymExpr)
    if (ex.op in [+, *]) && (length(ex.args) > 2)
        dup_inds = find_first_duplicates(ex.args)
        is_dup = [(i in dup_inds) for i in 1:length(ex.args)]
        identical_terms = ex.args[is_dup]
        if length(identical_terms) > 1
            if ex.op == +
                new_arg = length(identical_terms)*identical_terms[1]
            elseif ex.op == *
                new_arg = identical_terms[1]^length(identical_terms)
            end
            SymExpr(+, [new_arg, ex.args[.~(is_dup)]...])
        else
            ex
        end
    else
        ex
    end
end



function mult_zero(expr::SymExpr)
    if expr.op == *
        if length(find(0 .== expr.args)) > 0
            return 0
        end
    end
    expr
end
mult_zero(x::Union{Sym,Number}) = x


function remove_identity_operations(expr::SymExpr)
    if (expr.op == (^)) && (expr.args[2] == 1)
        return expr.args[1]
        
    elseif expr.op == +
        lst = find(0 .== expr.args)
        if (length(expr.args) == 2) && (length(lst) > 0)
            return expr.args[1:end .!= lst[1]]
        elseif length(lst) > 0
            return SymExpr(+, expr.args[1:end .!= lst[1]])
        end
        
    elseif expr.op == *
        lst = find(1 .== expr.args)
        if (length(expr.args) == 2) && (length(lst) > 0)
            return expr.args[1:end .!= lst[1]]
        elseif length(lst) > 0
            return SymExpr(*, expr.args[1:end .!= lst[1]])
        end
    end
    expr
end
remove_identity_operations(x::Union{Sym,Number}) = x



    
