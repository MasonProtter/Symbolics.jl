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


promote_SymForm(x::Number, y::Union{Sym,SymExpr}) = SymExpr
promote_SymForm(x::Union{Sym,SymExpr}, y::Number) = SymExpr
promote_SymForm(x::Union{Sym,SymExpr}, y::Union{Sym,SymExpr}) = SymExpr


SymNum = Union{Symbolic,Number}

function Base.atan(x::T, y::V) where {T<:SymNum,V<:SymNum} 
   promote_SymForm(x,y)(:atan, stripiden.([x,y]))
end
    
function Base.hypot(x::T, y::V) where {T<:SymNum,V<:SymNum} 
   promote_SymForm(x,y)(:hypot, stripiden.([x,y]))
end

function Base.max(x::T, y::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(x,y)(:max, stripiden.([x,y]))
end

function Base.min(x::T, y::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(x,y)(:min, stripiden.([x,y]))
end

function Base.:<(x::T, y::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(x,y)(:<, stripiden.([x,y]))
end

function SpecialFunctions.besselj(ν::T, x::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(ν,x)(:besselj, stripiden.([ν, x]))
end

function SpecialFunctions.besseli(ν::T, x::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(ν,x)(:besseli, stripiden.([ν, x]))
end

function SpecialFunctions.bessely(ν::T, x::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(ν,x)(:bessely, stripiden.([ν, x]))
end

function SpecialFunctions.besselk(ν::T, x::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(ν,x)(:besselk, stripiden.([ν, x]))
end

function SpecialFunctions.hankelh1(ν::T, x::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(ν,x)(:hankelh1, stripiden.([ν, x]))
end

function SpecialFunctions.hankelh2(ν::T, x::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(ν,x)(:hankelh2, stripiden.([ν, x]))
end

function SpecialFunctions.polygamma(m::T, x::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(m,x)(:polygamma, stripiden.([m, x]))
end
function SpecialFunctions.polygamma(m::Int, x::V) where {V<:SymNum} 
    promote_SymForm(m,x)(:polygamma, stripiden.([m, x]))
end


function SpecialFunctions.beta(a::T, b::V) where {T<:Number,V<:Symbolic} 
    promote_SymForm(a,b)(:beta, stripiden.([a, b]))
end
function SpecialFunctions.beta(a::T, b::V) where {T<:Symbolic,V<:Number} 
    promote_SymForm(a,b)(:beta, stripiden.([a, b]))
end
function SpecialFunctions.beta(a::T, b::V) where {T<:Symbolic,V<:Symbolic} 
    promote_SymForm(a,b)(:beta, stripiden.([a, b]))
end

function SpecialFunctions.lbeta(a::T, b::V) where {T<:SymNum,V<:SymNum} 
    promote_SymForm(a,b)(:lbeta, stripiden.([a, b]))
end


#_____________________________________________
# More math functions
for (M, f, arity) in DiffRules.diffrules()
    if arity == 1 && (M == :Base || M == :SpecialFunctions) && f ∉ [:inv, :+, :-, :abs] # [:bessely0, :besselj0, :bessely1, :besselj1]
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
