# [[file:~/Documents/Julia/scrap.org::*Simplification.jl][Simplification.jl:1]]
#----------------------------------------------------------------------------
# Some utility functions
#----------------------------------------------------------------------------

function Base.vcat(ex::T, arr::Array) where {T<:AbstractSymExpr}
    T(ex.op, vcat(ex.args, arr))
end

function trim(ex::T, index::Int) where {T<:AbstractSymExpr}
    T(ex.op, ex.args[1:end .!= index])
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


apply_f_to_pairs(f, x) = x
function apply_f_to_pairs(f, ex::T) where {T<:AbstractSymExpr}
    if length(ex.args) == 2
        return f(ex)
    elseif length(ex.args) > 2
        for i in 1:(length(ex.args)-1), j in (i+1):length(ex.args)
            old_arg = SymExpr(ex.op, [ex.args[i], ex.args[j]])
            newarg = f(old_arg)
            if newarg != old_arg
                newarglist = ex.args[1:end .!= i][1:end .!= j-1] #This should select everything but the i and j components since j>i
                return SymExpr(ex.op, vcat([newarg], newarglist))
            end
        end
    end
    ex
end

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# The main loop for recursively going through a symbolic expression and simplifying it
#----------------------------------------------------------------------------

simplify(x) = x
function simplify(ex::AbstractSymExpr)
    out1 = simplify_pass(ex)
    out2 = simplify_pass(out1)
    counter = 1
    while (out2 isa SymExpr) && (out1 isa SymExpr) && (out2 != out1)
        out1 = simplify_pass(out2)
        out2 = simplify_pass(out1)
        counter += 1
        if counter > 1000
            @warn "possible infinite loop in simplification rules. Breaking"
            return out2
        end 
    end
    out2
end

simplify_pass(x) = x
function simplify_pass(ex::AbstractSymExpr)
    postwalk(apply_algebraic_rules, ex)
end

apply_algebraic_rules(x) = x
function apply_algebraic_rules(expr::AbstractSymExpr)
    @> expr begin
        stripiden
        add_rules
        mult_rules
        exp_rules
        distribute_negation
        denest
        collect_numeric_terms
        collect_identical
    end
end

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# The simplification functions
#----------------------------------------------------------------------------


# addition_rules(x) = x
# function addition_rules(ex::T) where {T<:AbstractSymExpr}
#     if ex.op == :+
#         @> ex begin
#             remove_addative_identity
#         end
#     else
#         ex
#     end
# end

# remove_addative_identity(x) = x
# function remove_addative_identity(ex::T) where {T<:AbstractSymExpr}
#     if (0 in expr.args)
#         return +(expr.args[expr.args .!= 0]...)
#     end 
# end

# remove_addative_identity(x) = x
# function remove_addative_identity(ex::T) where {T<:AbstractSymExpr}
#     if (0 in expr.args)
#         return +(expr.args[expr.args .!= 0]...)
#     end 
# end

# # collect_over_op(x) = x
# # function collect_associative_terms(x, op) = x

#----------------------------------------------------------------------------
# Rules for Addition
#----------------------------------------------------------------------------
add_rules(x) = x
function add_rules(ex::T) where {T<:AbstractSymExpr}
    @> ex begin
        distribute_negation
        remove_addative_identity
        ex -> apply_f_to_pairs(factor_addition, ex)
    end
end

remove_addative_identity(x) = x
function remove_addative_identity(ex::T) where {T<:AbstractSymExpr}
    if (ex.op == :+) && (0 in ex.args)
        return +(ex.args[ex.args .!= 0]...)
    end
    ex
end

distribute_negation(x) = x
function distribute_negation(ex::T) where {T<:AbstractSymExpr}
    if (ex.op == Sym(:-)) && (length(ex.args) == 1) && (ex.args[1] isa AbstractSymExpr) && (ex.args[1].op == Sym(:+))
        T(:+, [-(arg) for arg in ex.args[1].args])
    else
        ex
    end
end


factor_addition(ex) = ex
function factor_addition(ex::T) where {T<:AbstractSymExpr}
    @match ex begin
        #SymExpr(:+, [x, SymExpr(:*, [a, x])]) => (a+1)*x
        SymExpr(:+, [SymExpr(:*, [a,b]), SymExpr(:*, [c,d])]), if b==d end => (a+c)*b
        SymExpr(:+, [SymExpr(:*, [a,b]), SymExpr(:*, [c,d])]), if b==c end => (a+d)*b
        SymExpr(:+, [SymExpr(:*, [a,b]), SymExpr(:*, [c,d])]), if a==c end => (b+d)*a
        SymExpr(:+, [SymExpr(:*, [a,b]), SymExpr(:*, [c,d])]), if a==d end => (b+c)*a
        SymExpr(:+, [a, SymExpr(:*, [b, c])]), if a==b end                 => (c+1)*a 
        SymExpr(:+, [a, SymExpr(:*, [b, c])]), if a==c end                 => (b+1)*a
        _                                                                  => ex
    end
end




#----------------------------------------------------------------------------
# Rules for Multiplication
#----------------------------------------------------------------------------
mult_rules(x) = x
function mult_rules(ex::T) where {T<:AbstractSymExpr}
    @> ex begin
        mult_by_zero
        mult_by_one
        x -> apply_f_to_pairs(factor_powers, x)
    end
end

mult_by_zero(ex) = ex
function mult_by_zero(ex::T) where {T<:AbstractSymExpr}
    if (ex.op == Sym(:*)) && (0 in ex.args)
        0
    else
        ex
    end
end

mult_by_one(ex) = ex
function mult_by_one(ex::T) where {T<:AbstractSymExpr}
    if (ex.op == Sym(:*)) && (1 in ex.args)
        newargs = ex.args[ex.args .!= 1]
        if newargs == []
            1
        else
            *(newargs...)
        end
    else
        ex
    end
end


factor_powers(x) = x
function factor_powers(ex::T) where {T<:AbstractSymExpr}
    @match ex begin
        SymExpr(:*, [SymExpr(:^, [a,b]), SymExpr(:^, [c,d])]), if a==c end => a^(b+d)
        SymExpr(:*, [a, SymExpr(:^, [b,c])]),                  if a==b end => a^(c+1) 
        SymExpr(:*, [SymExpr(:^, [a,b]), c]),                  if a==c end => a^(b+1) 
        SymExpr(:*, [a, b]),                                   if a==b end => a^2
        _                                                                  => ex
    end
end

#----------------------------------------------------------------------------
# Rules for Exponentiation
#----------------------------------------------------------------------------
exp_rules(x) = x
function exp_rules(ex::T) where {T<:AbstractSymExpr}
    @> ex begin
        exp_one
        exp_zero
    end
end

exp_one(x) = x
function exp_one(ex::T) where {T<:AbstractSymExpr}
    if (ex.op == Sym(:^)) && (ex.args[2] == 1)
        return ex.args[1]
    end
    ex
end

exp_zero(x) = x
function exp_zero(ex::T) where {T<:AbstractSymExpr}
    if (ex.op == Sym(:^)) && (ex.args[2] == 0)
        return 1
    end
    ex
end
    

#----------------------------------------------------------------------------
# More Misc. Rules
#----------------------------------------------------------------------------
remove_identity_operations(x) = x
function remove_identity_operations(expr::T) where {T<:AbstractSymExpr}
    if (expr.op == Sym(:^)) && (expr.args[2] == 1)
        return expr.args[1]
    elseif expr.op == :+
        if (0 in expr.args)
            return +(expr.args[expr.args .!= 0]...)
        end

    end
    expr
end


denest(x) = x
function denest(ex::AbstractSymExpr)
    (ex.op in [Sym(:+), Sym(:*)]) ? denest_op(ex, ex.op) : ex
end


function denest_op(ex, op)
    for arg in ex.args
        if (arg isa AbstractSymExpr) && (arg.op == op)
            ii = findall(ex.args .== arg)[1]
            return typeof(arg)(op, vcat(arg.args, ex.args[1:end .!= ii]))
        end
    end
    ex
end

collect_numeric_terms(x) = x
function collect_numeric_terms(ex::T) where {T<:SymExpr}
    if (ex.op in [:+, :*]) && (length(ex.args) > 2)
        is_numeric = isa.(ex.args, Union{Real, Complex})
        numbers = ex.args[is_numeric]
        if length(numbers) > 1
            new_arg = eval(ex.op.name)(numbers...)
            T(ex.op, [new_arg, ex.args[.~(is_numeric)]...])
        else
            ex
        end
    else
        ex
    end
end


collect_identical(x) = x
function collect_identical(ex::T) where {T<:AbstractSymExpr}
    if (ex.op in [:+, :*]) && (length(ex.args) > 1)
        dup_inds = find_first_duplicates(ex.args)
        is_dup = [(i in dup_inds) for i in 1:length(ex.args)]
        identical_terms = ex.args[is_dup]
        if length(identical_terms) > 1
            if ex.op == :+
                new_arg = length(identical_terms)*identical_terms[1]
            elseif ex.op == :*
                new_arg = identical_terms[1]^length(identical_terms)
            end
            eval(ex.op.name)(new_arg, ex.args[.~(is_dup)]...)
        else
            ex
        end
    else
        ex
    end
end

# eval_numeric(x) = x
# function eval_numeric(ex::T) where {T<:AbstractSymExpr}
#     if (ex.args isa Array{U,1} where {U<:Number}) && (try eval(Symbol(ex.op)) isa Function catch e; false end)
#         eval(Expr(ex))
#     else
#         ex
#     end
# end


# function mult_zero(expr::SymExpr)
#     if expr.op == *
#         if length(findall(0 .== expr.args)) > 0
#             return 0
#         end
#     end
#     expr
# end
# mult_zero(x::Union{Sym,Number}) = x


# function remove_identity_operations(expr::SymExpr)
#     if (expr.op == (^)) && (expr.args[2] == 1)
#         return expr.args[1]
        
#     elseif expr.op == +
#         lst = findall(0 .== expr.args)
#         if (length(expr.args) == 2) && (length(lst) > 0)
#             return expr.args[1:end .!= lst[1]]
#         elseif length(lst) > 0
#             return SymExpr(+, expr.args[1:end .!= lst[1]])
#         end
        
#     elseif expr.op == *
#         lst = findall(1 .== expr.args)
#         if (length(expr.args) == 2) && (length(lst) > 0)
#             return expr.args[1:end .!= lst[1]]
#         elseif length(lst) > 0
#             return SymExpr(*, expr.args[1:end .!= lst[1]])
#         end
#     end
#     expr
# end
# remove_identity_operations(x::Union{Sym,Number}) = x
# Simplification.jl:1 ends here
