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


#_____________________________________________
# other
Base.inv(x::T) where {T<:Symbolic} = promote(T)(:^, stripiden.([x, -1]))  |> simplify

Base.:( \ )(x::T,y::T) where {T<:Symbolic} = inv(x)*y

Base.abs(x::T) where {T<:Symbolic} = sqrt(x^2)

Base.conj(x::Union{AbstractSymExpr,AbstractSym}) = x

Base.atan(x::T, y::T) where {T<:Symbolic} = promote(T)(:atan, stripiden.([x,y]))
Base.hypot(x::T, y::T) where {T<:Symbolic} = promote(T)(:hypot, stripiden.([x,y]))
Base.max(x::T, y::T) where {T<:Symbolic} = promote(T)(:max, stripiden.([x,y]))
Base.min(x::T, y::T) where {T<:Symbolic} = promote(T)(:min, stripiden.([x,y]))


SpecialFunctions.besselj(ν::T, x::T) where {T<:Symbolic} = promote(T)(:besselj, stripiden.([ν, x]))
SpecialFunctions.besseli(ν::T, x::T) where {T<:Symbolic} = promote(T)(:besseli, stripiden.([ν, x]))
SpecialFunctions.besselk(ν::T, x::T) where {T<:Symbolic} = promote(T)(:besselk, stripiden.([ν, x]))
SpecialFunctions.hankelh1(ν::T, x::T) where {T<:Symbolic} = promote(T)(:hankelh1, stripiden.([ν, x]))
SpecialFunctions.hankelh2(ν::T, x::T) where {T<:Symbolic} = promote(T)(:hankelh2, stripiden.([ν, x]))
SpecialFunctions.bessely(ν::T, x::T) where {T<:Symbolic} = promote(T)(:bessely, stripiden.([ν, x]))
SpecialFunctions.polygamma(m::T, x::T) where {T<:Symbolic} = promote(T)(:polygamma, stripiden.([m, x]))
SpecialFunctions.beta(a::T, b::T) where {T<:Symbolic} = promote(T)(:beta, stripiden.([a, b]))
SpecialFunctions.lbeta(a::T, b::T) where {T<:Symbolic} = promote(T)(:lbeta, stripiden.([a, b]))

#_____________________________________________
# More math functions
for (M, f, arity) in DiffRules.diffrules()
    if arity == 1 && (M == :Base || M == :SpecialFunctions) && f ∉ [:inv, :+, :-, :abs, :trigamma, :digamma, :invdigamma, :gamma, :lgamma] # [:bessely0, :besselj0, :bessely1, :besselj1]
        deriv = DiffRules.diffrule(M, f, :x)
        @eval begin
            $M.$f(x::T) where {T<:Symbolic} = promote(T)(Symbol($f), stripiden.([x]))  |> simplify
        end
    # elseif arity == 2 && (M == :Base || M == :SpecialFunctions) && f ∉ [:+, :-, :*, :/, :^]
    #     deriv = DiffRules.diffrule(M, f, :x, :y)
    #     @eval begin
    #         $M.$f(x::T, y::T) where {T<:Symbolic} = promote(T)(Symbol($f), stripiden.([x, y]))  |> simplify
    #     end
    end
end
# SymbolicAlgebra.jl:1 ends here
