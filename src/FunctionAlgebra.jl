# FunctionAlgebra.jl

# [[file:~/Documents/Julia/scrap.org::*FunctionAlgebra.jl][FunctionAlgebra.jl:1]]
#_____________________________________________
# Addition

function Base.:+(f1::Union{Function,Operator}, f2::Union{Function,Operator})
    if f1 == f2
	t -> 2*f1(t)
    else
	t -> f1(t) + f2(t)
    end
end

Base.:+(a::Number, f::Union{Function,Operator}) = t -> a + f(t)
Base.:+(f::Union{Function,Operator}, a::Number) = t -> f(t) + a

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

Base.:-(a::Number, f::Union{Function,Operator}) = t -> a - f(t)
Base.:-(f::Union{Function,Operator}, a::Number) = t -> f(t) - a

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

Base.:*(a::Number, f::Union{Function,Operator}) = t -> a*f(t)
Base.:*(f::Union{Function,Operator}, a::Number) = *(a, f)

#_____________________________________________
# Division

function Base.:/(f1::Function, f2::Function)
    if f1 == f2
	t -> 1
    else
	t -> f1(t)/f2(t)
    end
end

Base.:/(a::Number, f::Function) = t -> a/f(t)
Base.:/(f::Function, a::Number) = t -> f(t)/a

#_____________________________________________
# Exponents

function Base.:^(a::Operator, b::Integer)
    function (t)
	foldl((x,y)->a(x),1:b,init=t)
    end
end
# FunctionAlgebra.jl:1 ends here
