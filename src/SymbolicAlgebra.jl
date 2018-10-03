# SymbolicAlgebra.jl

# [[file:~/Documents/Julia/scrap.org::*SymbolicAlgebra.jl][SymbolicAlgebra.jl:1]]
#_____________________________________________
# Promotion Rules

Base.promote(::Type{Sym}) = SymExpr
Base.promote(::Type{SymExpr}) = SymExpr

Base.promote(x::T, y::Number) where {T<:Symbolic} = (promote(T)(:identity, [x]), promote(T)(:identity, [y]))
Base.promote(x::Number, y::T) where {T<:Symbolic} = (promote(T)(:identity, [x]), promote(T)(:identity, [y]))
Base.promote(x::Sym, y::SymExpr) = (SymExpr(:identity, [x]), y)
Base.promote(x::SymExpr, y::Sym) = (x, SymExpr(:identity, [y]))


#_____________________________________________
# Addition
Base.:(+)(x::T, y::T) where {T<:Symbolic} = promote(T)(:+, stripiden.([x, y])) |> simplify
Base.:+(x::Symbolic) = x #|> simplify


#_____________________________________________
# Subtraction
Base.:(-)(x::T, y::T) where {T<:Symbolic} = promote(T)(:+, stripiden.([x, -y]))  |> simplify
Base.:(-)(x::T) where {T<:Symbolic} = promote(T)(:*, [-1, x])  |> simplify


#_____________________________________________
# Multiplication
Base.:(*)(x::T, y::T) where {T<:Symbolic} = ((x == y) ? promote(T)(:^, stripiden.([x, 2])) :
                                                        promote(T)(:*, stripiden.([x, y])))  |> simplify
LinearAlgebra.dot(a::T, b::T) where {T<:Symbolic} = a*b
Base.zero(a::Symbolic) = 0


#_____________________________________________
# Division
Base.:(/)(x::T, y::T) where {T<:Symbolic} = promote(T)(:*, stripiden.([x, y^-1]))  |> simplify

#_____________________________________________
# Exponents
Base.:(^)(x::T, y::T) where {T<:Symbolic}   = promote(T)(:^, stripiden.([x, y]))  |> simplify
Base.:(^)(x::T, y::Int) where {T<:Symbolic} = promote(T)(:^, stripiden.([x, y]))  |> simplify
# Base.exp(x::T) where {T<:Symbolic} = promote(T)(:exp, stripiden.([x]))  |> simplify

# Base.sqrt(x::T) where {T<:Symbolic} = promote(T)(:sqrt, stripiden.([x]))  |> simplify

#_____________________________________________
# inv
Base.inv(x::T) where {T<:Symbolic} = promote(T)(:^, stripiden.([x, -1]))  |> simplify

#_____________________________________________
# Logarithms
# Base.log(x::T) where {T<:Symbolic} = promote(T)(:log, stripiden.([x]))  |> simplify

#_____________________________________________
# Trig
# Base.cos(x::T) where {T<:Symbolic} = promote(T)(:cos, stripiden.([x]))  |> simplify
# Base.sin(x::T) where {T<:Symbolic} = promote(T)(:sin, stripiden.([x]))  |> simplify
# Base.tan(x::T) where {T<:Symbolic} = promote(T)(:tan, stripiden.([x]))  |> simplify

Base.abs(x::T) where {T<:Symbolic} = sqrt(x^2)

#_____________________________________________
# More math functions
for (M, f, arity) in DiffRules.diffrules()
    if arity == 1 && (M == :Base || M == :SpecialFunctions) && f ∉ [:inv, :+, :-, :abs, :trigamma, :digamma, :invdigamma, :gamma, :lgamma] # [:bessely0, :besselj0, :bessely1, :besselj1]
        deriv = DiffRules.diffrule(M, f, :x)
        @eval begin
            $M.$f(x::T) where {T<:Symbolic} = promote(T)(Symbol($f), stripiden.([x]))  |> simplify
        end
    elseif arity == 2 && (M == :Base || M == :SpecialFunctions) && f ∉ [:+, :-, :*, :/, :^]
        deriv = DiffRules.diffrule(M, f, :x, :y)
        @eval begin
            $M.$f(x::T, y::T) where {T<:Symbolic} = promote(T)(Symbol($f), stripiden.([x, y]))  |> simplify
        end
    end
end
# SymbolicAlgebra.jl:1 ends here
