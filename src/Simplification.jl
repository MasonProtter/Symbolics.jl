ex = Union{Sym, SymExpr}

walk(x, inner, outer) = outer(x)
walk(x::SymExpr, inner, outer) = outer(SymExpr(inner(x.op), map(inner, x.args)))
walk(x::Expr, inner, outer) = outer(Expr(x.head, map(inner, x.args)...))
postwalk(f, x) = walk(x, x -> postwalk(f, x), f)


function expand_expression(expr::SymExpr)
    postwalk(x -> expand_term(x), expr)
end


expand_expression(a::Union{Number, Sym}) = a

function simplification_loop(expr::SymExpr)
    out1 = walk_expand_unravel(expr)
    out2 = walk_expand_unravel(out1)
    while (out2 isa SymExpr) && (out1 isa SymExpr) && (out2.args != out1.args)
        out1 = walk_expand_unravel(out2)
        out2 = walk_expand_unravel(out1)
    end
    out2
end

simplification_loop(a::Union{Number, Sym}) = a

function walk_expand_unravel(expr::SymExpr)
    postwalk(x -> expand_term(x), expr)
end
walk_expand_unravel(a::Sym) = a
walk_expand_unravel(num::Number) = num


function unravel_brackets(expr::SymExpr)
    if expr.op == +
        for i in 1:length(expr.args)
            if (typeof(expr.args[i]) == SymExpr) && (length(expr.args[i].args) >= 2) && ((expr.args[i]).op == +)
                x = expr.args[i]
                fn = x.op
                deleteat!(expr.args, i)
                for j in 1:length(x.args)
                    insert!(expr.args, 1, j== 1 ? (x.args[j]) : fn(x.args[j]))
                end
            end
        end
    end
    if expr.op == *
        for i in 1:length(expr.args)
            if (typeof(expr.args[i]) == SymExpr) && (length(expr.args[i].args) >= 2) && ((expr.args[i]).op == *)
                x = expr.args[i]
                fn = x.op
                deleteat!(expr.args, i)
                for j in 1:length(x.args)
                    insert!(expr.args, 1, x.args[j])
                end
            end
        end
    end
    SymExpr(expr)
end
unravel_brackets(a::Union{Number, Sym}) = a


function expand_term(expr::SymExpr)
    expr |> apply_algebraic_rules
end
expand_term(a::Union{Sym, Number, Symbol, Function}) = a



function apply_algebraic_rules(expr::SymExpr)
    @> expr begin
        distribute_negation
        negate
        unravel_brackets
        collect_numeric
        collect_identical
        expt_one
        apply_mult_zero
        remove_identity_operations
        evaluate_numeric
        pos_x_equals_x
    end
end


function distribute_negation(expr::ex)
    @capture(expr |> Expr, -(+(x__))) && (expr = +([-x[i] for i in 1:length(x)]...))
    SymExpr(expr)
end

function negate(expr::ex)
    @capture(Expr(expr), -x_) && (expr = -1*x)
    SymExpr(expr)
end

function pos_x_equals_x(expr::ex)
    if (typeof(expr) == SymExpr) && (expr.op == :+) && (length(expr.args) == 1)
        expr = expr.args[1]
    end
    expr
end
pos_x_equals_x(num::Number) = num


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


function collect_identical(expr::SymExpr)
    f = expr.op
    body = expr.args
    duplicate_indices = find_first_duplicates(body)
    multiplicity = length(duplicate_indices)
    if (f == +) && (multiplicity > 0)
        x = body[duplicate_indices[1]]
        deleteat!(body, duplicate_indices)
        insert!(body, duplicate_indices[1], multiplicity*x)
        if length(body) == 1
            expr = body[1]
        else
            expr = SymExpr(f, body)
        end
    end
    if (expr.args[1] == *) && (multiplicity > 0)
        x = body[duplicate_indices[1]]
        deleteat!(body, duplicate_indices)
        insert!(body, duplicate_indices[1], x^multiplicity)
        if length(body) == 1
            expr = body[1]
        else
            expr = SymExpr(f, body)
        end
    end
    expr
end

collect_identical(a::Union{Number,Sym}) = a


function collect_numeric(expr::SymExpr)
    f = expr.op
    if length(expr.args) > 2
        body = expr.args
        if (f == +) || (f == *)
            indices = find(x -> x isa Number, body)
            if length(indices) > 1
                numbers = body[indices]
                deleteat!(body, indices)
                insert!(body, 1, eval(f)(numbers...))
                expr = SymExpr(f, body)
            end
        end
    end
    SymExpr(expr)
end
collect_numeric(a::Union{Number, Sym}) = a

function expt_one(expr::ex)
    if expr.op == (^) && expr.args[2] == 1
        expr.args[1]
    else
        expr
    end
end
expt_one(num::Number) = num

function apply_mult_zero(expr::ex)
    if (typeof(expr) == SymExpr) && (expr.op == *)
        if length(find(x -> x == 0, expr.args)) > 0
            expr = 0
        end
    end
    expr
end
apply_mult_zero(num::Number) = num

function remove_identity_operations(expr::SymExpr)
    if expr.op == +
        lst = find(x -> x == 0 , expr.args)
        if length(lst) > 0
            deleteat!(expr.args, lst[1])
        end
    elseif expr.args[1] == *
        lst = find(x -> x == 1 , expr.args)
        if (length(expr.args) == 2) && (length(find(x -> (x != 1), expr.args)) == 1)
            return expr.args[find(x -> (x != 1), expr.args)...]
        end
        if (length(lst) > 0)
            deleteat!(expr.args, lst[1])
        end
    end
    expr
end
remove_identity_operations(sym::Sym) = sym
remove_identity_operations(num::Number) = num


function evaluate_numeric(expr::SymExpr)
    if (expr.args[1:end] |> is_all_numbers)
        eval(expr)
    else
        expr
    end
end
evaluate_numeric(sym::Sym) = sym
evaluate_numeric(num::Number) = num


function is_all_numbers(list::Array)
    for n in list
        if !(typeof(n) <: Number)
            return false
        end
    end
    true
end

