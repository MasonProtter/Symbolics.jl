Symy = Union{Sym,SymExpr}
#_____________________________________________
# Addition

Base.:+(x::Symy, y::Number) = y == 0 ? x : SymExpr(:($x+$y))
Base.:+(x::Number, y::Symy) = x == 0 ? y : SymExpr(:($x+$y))

function Base.:+(x::Symy, y::Symy)
    if x == y
        SymExpr(:(2*$x))
    elseif x == -y
        0
    else
        SymExpr(:($x+$y))
    end
end

Base.:+(x::Symy) = x

#_____________________________________________
# Subtraction

Base.:-(x::Symy, y::Number) = y == 0 ? x : SymExpr(:($x-$y))
Base.:-(x::Number, y::Symy) = x == 0 ? -y : SymExpr(:($x-$y))

function Base.:-(x::Symy, y::Symy)
    if x == y
        0
    elseif x == -y
        SymExpr(:(2$x))
    else
        SymExpr(:($x-$y))
    end
end

function Base.:-(x::Sym)
    SymExpr(:(-$x))
end

isUnaryOperation(ex::SymExpr) = length(ex.args) == 2
car(x::SymExpr) = x.args[1]

function Base.:-(x::SymExpr)
    if (car(x) == :-) && (x |> isUnaryOperation)
        SymExpr(x.args[2])
    else
        SymExpr(:(-$x))
    end
end

#_____________________________________________
# Multiplication

Base.:*(x::Symy, y::Number) = y == 0 ? 0 : y == 1 ? x : SymExpr(:($x*$y))
Base.:*(x::Number, y::Symy) = x == 0 ? 0 : x == 1 ? y : SymExpr(:($x*$y))

function Base.:*(x::Symy,y::Symy)
    if x == y
        SymExpr(:($x^2))
    elseif x == -y
        SymExpr(:(-$x^2))
    else
        SymExpr(:($x*$y))
    end
end


Base.dot(a::Mathy, b::Mathy) = a*b
Base.zero(a::Mathy) = 0

#_____________________________________________
# Division

Base.:/(x::Symy, y::Number) = y == 0 ? Inf : y == 1 ? x : y == -1 ? -x : SymExpr(:($x/$y))
Base.:/(x::Number, y::Symy) = x == 0 ? 0 : SymExpr(:($x/$y))

function Base.:/(x::Symy, y::Symy)
    if x == y
        1
    elseif x == -y
        -1
    else
        SymExpr(:($x/$y))
    end
end

#_____________________________________________
# Exponents

Base.:^(x::Symy, y::Number) = y == 0 ? 1 : y == 1 ? x : SymExpr(:($x^$y))
Base.:^(x::Symy, y::Int) = y == 0 ? 1 : y == 1 ? x : SymExpr(:($x^$y))
Base.:^(x::Number, y::Symy) = x == 0 ? 0 : x == 1 ? 1 : SymExpr(:($x^$y))
Base.:^(x::Symy, y::Symy) = SymExpr(:($x^$y))


#_____________________________________________
# Logarithms
Base.log(x::Symy) = SymExpr(:(log($x)))



#_____________________________________________
# Trig
Base.sin(x::Symy) = SymExpr(:(sin($x)))
Base.cos(x::Symy) = SymExpr(:(cos($x)))

#______________________________________________
#Commutator
QMathy = Union{Operator, Mathy}
function commutator(x::Operator,y::Operator)
    x*y - y*x
end
