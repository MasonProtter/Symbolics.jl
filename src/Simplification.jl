ex = Union{Sym, Expr}


function expand_expression(expr::Expr)
    MacroTools.postwalk(x -> expand_term(x), expr)
end
expand_expression(a::Union{Number, Sym}) = a

function simplification_loop(expr::Expr)
    out1 = walk_expand_unravel(expr)
    out2 = walk_expand_unravel(out1)
    while out2 != out1
        out1 = walk_expand_unravel(out2)
        out2 = walk_expand_unravel(out1)
    end
    out2
end

simplification_loop(a::Union{Number, Sym}) = a


function walk_expand_unravel(expr::Expr)
    MacroTools.prewalk(x -> expand_term(x), expr)
end
walk_expand_unravel(a::Sym) = a
walk_expand_unravel(num::Number) = num



function unravel_brackets(expr_in::Expr)
    expr = copy(expr_in)
    if expr.args[1] == :+
        for i in 2:length(expr.args)
            if (typeof(expr.args[i]) == Expr) && (length(expr.args[i].args) >= 3) && ((expr.args[i]).args[1] == :+)
                x = expr.args[i]
                fn = eval(x.args[1])
                deleteat!(expr.args, i)
                for j in 2:length(x.args)
                    insert!(expr.args, i+j-2, j== 2 ? (x.args[j]) : fn(x.args[j]))
                end
            end
        end
    end
    if expr.args[1] == :*
        for i in 2:length(expr.args)
            if (typeof(expr.args[i]) == Expr) && (length(expr.args[i].args) >= 3) && ((expr.args[i]).args[1] == :*)
                x = expr.args[i]
                fn = eval(x.args[1])
                deleteat!(expr.args, i)
                for j in 2:length(x.args)
                    insert!(expr.args, i+j-2, (x.args[j]))
                end
            end
        end
    end
    expr
end
unravel_brackets(a::Union{Number, Sym}) = a


function expand_term(expr::Expr)
    expr |> apply_algebraic_rules
end
expand_term(a::Union{Sym,Number, Symbol}) = a
expand_term



function apply_algebraic_rules(expr::Expr)
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
    @capture(expr, -(+(x__))) && (expr = +([-x[i] for i in 1:length(x)]...))
    expr
end

function negate(expr::ex)
    @capture(expr, -x_) && (expr = -1*x)
    expr
end

function pos_x_equals_x(expr::ex)
    if (typeof(expr) == Expr) && (expr.args[1] == :+) && (length(expr.args) == 2)
        expr = expr.args[2]
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


function collect_identical(expr::Expr)
    f = expr.args[1]
    body = expr.args[2:end]
    duplicate_indices = find_first_duplicates(body)
    multiplicity = length(duplicate_indices)

    if (expr.args[1] == :+) && (multiplicity > 0)
        x = body[duplicate_indices[1]]
        deleteat!(body, duplicate_indices)
        insert!(body, duplicate_indices[1], multiplicity*x)
        if length(body) == 1
            expr = body[1]
        else
            expr = Expr(:call, f, body...)
        end
    end
    if (expr.args[1] == :*) && (multiplicity > 0)
        x = body[duplicate_indices[1]]
        deleteat!(body, duplicate_indices)
        insert!(body, duplicate_indices[1], x^multiplicity)
        if length(body) == 1
            expr = body[1]
        else
            expr = Expr(:call, f, body...)
        end
    end
    expr
end

collect_identical(a::Union{Number,Sym}) = a


function collect_numeric(expr::Expr)
    f = expr.args[1]
    if length(expr.args) > 3
        body = expr.args[2:end]
        if (f == :+) || (f == :*)
            indices = find(x -> x isa Number, body)
            if length(indices) > 1
                numbers = body[indices]
                deleteat!(body, indices)
                insert!(body, 1, eval(f)(numbers...))
                expr = Expr(:call, f, body...)
            end
        end
    end
    expr
end
collect_numeric(a::Union{Number, Sym}) = a


function expt_one(expr::ex)
    @capture(expr, x_^1) && (expr = x)
    expr
end
expt_one(num::Number) = num

function apply_mult_zero(expr::ex)
    if (typeof(expr) == Expr) && (expr.args[1] == :*)
        if length(find(x -> x == 0, expr.args)) > 0
            expr = 0
        end
    end
    expr
end
apply_mult_zero(num::Number) = num

function remove_identity_operations(expr::Expr)
    if expr.args[1] == :+
        lst = find(x -> x == 0 , expr.args)
        if length(lst) > 0
            deleteat!(expr.args, lst[1])
        end
    elseif expr.args[1] == :*
        lst = find(x -> x == 1 , expr.args)
        if (length(expr.args) == 3) && (length(find(x -> (x != 1) && (x != :*), expr.args)) == 1)
            return expr.args[find(x -> (x != 1) && (x != :*), expr.args)...]
        end
        if (length(lst) > 0)
            deleteat!(expr.args, lst[1])
        end
    end
    expr
end
remove_identity_operations(sym::Sym) = sym
remove_identity_operations(num::Number) = num


function evaluate_numeric(expr::Expr)
    if (expr.args[2:end] |> is_all_numbers) && (expr.args[1] != :D)
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
