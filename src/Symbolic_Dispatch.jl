
#_____________________________________________
# Addition

function Base.:+(f1::Union{Function,Operator}, f2::Union{Function,Operator})
    if f1 == f2
        t -> 2*f1(t)
    else
        t -> f1(t) + f2(t)
    end
end

Base.:+(a::Mathy, f::Union{Function,Operator}) = t -> a + f(t)
Base.:+(f::Union{Function,Operator}, a::Mathy) = t -> f(t) + a


function Base.:+(x::Mathy, y::Mathy)
    if x == y
        SymExpr(:(2*$x))
    elseif x == -y
        0
    elseif x == 0
        y
    elseif y == 0
        x
    else
        SymExpr(:($x+$y))
    end
end

Base.:+(x::Mathy) = x


#_____________________________________________
# Subtraction
function Base.:-(f1::Union{Function,Operator}, f2::Union{Function,Operator})
    if f1 == f2
        function (t)
            0
        end
    else
        function (t)
            f1(t) - f2(t)
        end
    end
end

Base.:-(a::Mathy, f::Union{Function,Operator}) = t -> a - f(t)
Base.:-(f::Union{Function,Operator}, a::Mathy) = t -> f(t) - a


function Base.:-(x::Mathy, y::Mathy)
    if x == y
        0
    elseif x == -y
        SymExpr(:(2$x))
    elseif x == 0
        -y
    elseif y == 0
        x
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
function Base.:*(f1::Function, f2::Function)
    if f1 == f2
        t -> f1(t)*f1(t)
    else
        t -> f1(t)*f2(t)
    end
end

function Base.:*(f1::Operator, f2::Operator)
    t -> (f1(f2))(t)
end


Base.:*(a::Mathy, f::Union{Function,Operator}) = t -> a*f(t)
Base.:*(f::Union{Function,Operator}, a::Mathy) = *(a, f)

function Base.:*(x::Mathy,y::Mathy)
    if x == y
        SymExpr(:($x^2))
    elseif x == -y
        SymExpr(:(-$x^2))
    elseif x == 1
        y
    elseif y == 1
        x
    elseif (x == 0) || (y == 0)
        0
    else
        SymExpr(:($x*$y))
    end
end


Base.dot(a::Mathy, b::Mathy) = a*b
Base.zero(a::Mathy) = 0

#_____________________________________________
# Division

function Base.:/(f1::Function, f2::Function)
    if f1 == f2
        t -> 1
    else
        t -> f1(t)/f2(t)
    end
end

Base.:/(a::Mathy, f::Function) = t -> a/f(t)
Base.:/(f::Function, a::Mathy) = t -> f(t)/a

function Base.:/(x::Mathy, y::Mathy)
    if x == y
        1
    elseif x == -y
        -1
    elseif y == 1
        x
    else
        SymExpr(:($x/$y))
    end
end

#_____________________________________________
# Exponents

function Base.:^(a::Operator, b::Integer)
    function (t)
        foldl((x,y)->a(x),t,1:b)
    end
end

function Base.:^(x::Mathy, y::Mathy)
    if y == 0
        1
    elseif y == 1
        x
    else
        SymExpr(:($x^$y))
    end
end

Base.:^(x::Mathy, y::Int) = y == 1 ? x : y == 0 ? 1: SymExpr(:($x^$y))


#_____________________________________________
# Logarithms
Base.log(x::Mathy) = SymExpr(:(log($x)))



#_____________________________________________
# Trig
Base.sin(x::Mathy) = SymExpr(:(sin($x)))
Base.cos(x::Mathy) = SymExpr(:(cos($x)))

#______________________________________________
#Commutator
QMathy = Union{Operator, Mathy}
function commutator(x::Operator,y::Operator)
    x*y - y*x
end
