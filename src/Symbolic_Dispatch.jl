import Base.+
import Base.-
import Base.*
import Base.^
import Base./
import Base.log
import Base.sin
import Base.cos
import Base.dot
import Base.zero
import Base.show




#_____________________________________________
# Addition

function +(f1::Function, f2::Function)
    if f1 == f2
        t -> 2*f1(t)
    else
        t -> f1(t) + f2(t)
    end
end

+(a::Number, f::Function) = t -> a + f(t)
+(f::Function, a::Number) = +(a::Number, f::Function)


function +(a::ex, b::ex)
    if a == b
        SymExpr(:(2 * $a))
    else
        SymExpr(:($a + $b))
    end
end

function +(a::ex, b::T where T<:Number)
    SymExpr(:($a + $b))
end

+(b::T where T<:Number, a::ex) = +(a, b)

+(a::ex) = a

#_____________________________________________
# Subtraction
function -(f1::Function, f2::Function)
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

-(a::Number, f::Function) = t -> a - f(t)
-(f::Function, a::Number) = t -> f(t) - a


function -(a::ex, b::ex)
    if a == b
        0
    else
        SymExpr(:($a + -$b))
    end
end

-(a::ex, b::Number) = SymExpr(:($a + -$b))

-(b::Number, a::ex) = SymExpr(:($b + -$a))

-(a::ex) = SymExpr(:(-1*$a))


#_____________________________________________
# Multiplication
function *(f1::Function, f2::Function)
    if f1 == f2
        t -> f1(t)*f1(t)
    else
        t -> f1(t)*f2(t)
    end
end

function *(f1::Operator, f2::Function)
    t -> (f1(f2))(t)
end

*(a::Number, f::Function) = t -> a*f(t)
*(f::Function, a::Number) = *(a::Number, f::Function)

function *(a::ex, b::ex)
    if (a == b) && (typeof(a) == Sym) && (typeof(b) == Sym)
        SymExpr(:($a^2))
    else
        SymExpr(:($a*$b))
    end
end


function *(a::ex, b::Number)
    if b == 1
        a
    elseif b == 0
        0
    else
        SymExpr(:($b * $a))
    end
end

*(b::Number, a::ex) = *(a, b)

dot(a::Union{ex, Number}, b::Union{ex, Number}) = a*b
zero(a::ex) = 0

#_____________________________________________
# Division

function /(f1::Function, f2::Function)
    if f1 == f2
        t -> 1
    else
        t -> f1(t)/f2(t)
    end
end

/(a::Number, f::Function) = t -> a/f(t)
/(f::Function, a::Number) = t -> f(t)/a

function /(a::ex, b::ex)
    if a == b
        1
    else
        SymExpr(:($a / $b))
    end
end


function /(a::ex, b::T where T<:Number)
    if b == 1
        a
    else
        SymExpr(:($a / $b))
    end
end


function /(b::T where T<:Number, a::ex)
    if b == 1
        SymExpr(:(1/$a))
    else
        SymExpr(:($a / $b))
    end
end



#_____________________________________________
# Exponents

function ^(a::Operator, b::Integer)
    function (t)
        foldl((x,y)->a(x),t,1:b)
    end
end

function ^(a::ex, b::Number)
    if b == 1
        SymExpr(:($a))
    else
        SymExpr(:($a^$b))
    end
end

function ^(a::ex, b::Integer)
    if b == 1
        SymExpr(:($a))
    else
        SymExpr(:($a^$b))
    end
end


function ^(a::Number, b::ex)
    if a == 1
        1
    else
        SymExpr(:($a^$b))
    end
end

^(a::ex, b::ex) = SymExpr(:($a^$b))


#_____________________________________________
# Logarithms
log(a::ex) = SymExpr(:(log($a)))



#_____________________________________________
# Trig
sin(x::ex) = SymExpr(:(sin($x)))
cos(x::ex) = SymExpr(:(cos($x)))
