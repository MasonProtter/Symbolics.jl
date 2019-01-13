# SymbolicAlgebra.jl

# [[file:~/Documents/Julia/scrap.org::*SymbolicAlgebra.jl][SymbolicAlgebra.jl:1]]
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


SymNum = Union{Symbolic,Number}

function Base.atan(x::T, y::V) where {T<:SymNum,V<:SymNum}
   promote_SymForm(x,y)(:atan, stripiden.([x,y]))
end

function Base.hypot(x::T, y::V) where {T<:Symbolic,V<:Symbolic}
   promote_SymForm(x,y)(:hypot, stripiden.([x,y]))
end
function Base.hypot(x::T, y::V) where {T<:Number,V<:Symbolic}
   promote_SymForm(x,y)(:hypot, stripiden.([x,y]))
end
function Base.hypot(x::T, y::V) where {T<:Symbolic,V<:Number}
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

function SpecialFunctions.lbeta(a::T, b::V) where {T<:Number,V<:Symbolic}
    promote_SymForm(a,b)(:lbeta, stripiden.([a, b]))
end
function SpecialFunctions.lbeta(a::T, b::V) where {T<:Symbolic,V<:Number}
    promote_SymForm(a,b)(:lbeta, stripiden.([a, b]))
end
function SpecialFunctions.lbeta(a::T, b::V) where {T<:Symbolic,V<:Symbolic}
    promote_SymForm(a,b)(:lbeta, stripiden.([a, b]))
end


#_____________________________________________
# More math functions
for (M, f, arity) in DiffRules.diffrules()
    if arity == 1 && (M == :Base || M == :SpecialFunctions) && f ∉ [:inv, :+, :-, :abs]
        @eval begin
            $M.$f(x::T) where {T<:Symbolic} = promote(T)(Symbol($f), stripiden.([x]))  |> simplify
        end
    end
end

# This is different from a possible `isnegative` in that `-x` could be
# positive, if `x` is negative. This function returns `true` if there
# is a factor `-1` present.
isnegated(::Number) = false
isnegated(r::Real) = r < 0
isnegated(s::SymExpr) = s.op.name == :(*) && findfirst(isequal(-1), s.args) !== nothing

isdenominator(a::Number) = false
isdenominator(a::SymExpr) = (a.op.name == :(^) && isnegated(a.args[2]))

Base.numerator(s::Sym) = s
Base.denominator(s::Sym) = 1

function Base.numerator(expr::SymExpr)
    isdenominator(expr) && return 1
    if expr.op.name == :(*)
        args = filter(a -> !isdenominator(a), expr.args)
        length(args) > 1 ? prod(args) : args[1]
    else
        expr
    end
end

function Base.denominator(expr::SymExpr)
    # # This would be the simplest implemenation, if simplification
    # # worked (e.g. inv(xy/sin(x)) becomes (x * y * sin(x) ^ -1) ^ -1
    # # at the moment):
    # return numerator(inv(expr))
    if expr.op.name == :(*)
        den = filter(isdenominator, expr.args)
        isempty(den) && return 1
        # Negate exponents of all factors that should be in the
        # denominator.
        args = map(inv, den)#  do a
        #     a.args[1] ^ (-a.args[2])
        # end
        length(args) > 1 ? prod(args) : args[1]
    elseif expr.op.name == :(^)
        numerator(inv(expr))
    else
        1
    end
end

# SymbolicAlgebra.jl:1 ends here
