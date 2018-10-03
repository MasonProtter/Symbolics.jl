# Calculus.jl

# [[file:~/Documents/Julia/scrap.org::*Calculus.jl][Calculus.jl:1]]

Base.adjoint(Dx::Differential) = Differential(tag => adjoint(value) for (tag, value) in Dx.terms)
#---------------------------------------------------------------
#---------------------------------------------------------------
# Addition of Differentials

function Base.:+(x::Differential, y::Number)
    x + Differential([DTag()], [y])
end

function Base.:+(x::Number, y::Differential)
    Differential([DTag()], [x]) + y
end


function Base.:+(x::Differential, y::Differential)
    tags = tagUnion(x,y)
    values = [((try x[tag] catch; 0 end) + (try y[tag] catch; 0 end)) for tag in tags]
    Differential(tags, values)
end

#---------------------------------------------------------------
#---------------------------------------------------------------
# Multiplication of Differentials

function Base.:*(x::Differential, y::Number)
    Differential(tag => value * y for (tag, value) in x.terms)
end

function Base.:*(y::Number, x::Differential)
    Differential(tag => y * value for (tag, value) in x.terms)
end

function Base.:*(x::Differential, y::Differential)
    out = Differential([],[0])
    for (k1,v1) in x.terms
        for (k2,v2) in y.terms
            out += Differential([k1*k2], [v1*v2])
        end
    end
    out
end

function Base.:*(t1::DTag,t2::DTag)
    if vcat(t1.tag,t2.tag) |> hasDuplicates
        DTag(-1)
    else
        DTag(vcat(t1.tag,t2.tag) |> sort)
    end
end

Base.one(Dx::Differential)  = 1.0
Base.zero(Dx::Differential) = 0.0

#---------------------------------------------------------------
#---------------------------------------------------------------
# constructors for new unary and binary operations

function unaryOp(f::T, Df::U) where {T<:Union{Function,SymExpr},U<:Union{Function,SymExpr}}
    function (Dx::Differential)
        f(Dx[1:end-1]) + Df(Dx[1:end-1])*Dx[end]
    end
end

function binaryOp(f::Function, Dfx::Function, Dfy::Function)
    function (x, y)
        if (x isa Differential) && (y isa Differential)
            Dx = x
            Dy = y;
            f(Dx[1:end-1],Dy[1:end-1]) + Dfx(Dx[1:end-1], Dy[1:end-1])*Dx[end] + Dfy(Dx[1:end-1], Dy[1:end-1])*Dy[end]
        elseif  (x isa Differential)
            Dx = x
            f(Dx[1:end-1],y) + Dfx(Dx[1:end-1], y)*Dx[end]
        elseif y isa Differential
            Dy = y
            f(x,Dy[1:end-1]) + Dfy(x, Dy[1:end-1])*Dy[end]
        else
            throw("one of two arguments must be a differential")
        end
    end
end

Base.:-(Dx::Differential, y::Number) = unaryOp(x -> x - y, x -> 1)(Dx)
Base.:-(x::Number, Dy::Differential) = unaryOp(y -> x - y, y -> -1)(Dy)
Base.:-(Dx::Differential, Dy::Differential) = binaryOp((x,y) -> x - y,
                                                       (x,y) -> 1,
                                                       (x,y) -> -1)(Dx,Dy)

Base.:/(Dx::Differential,y::Number) = unaryOp(Dx -> Dx/y, Dx -> 1/y)(Dx)
Base.:/(x::Number,Dy::Differential) = unaryOp(Dy -> x/Dy, Dy -> -x/(Dy)^2)(Dy)
Base.:/(Dx::Differential,Dy::Differential) = binaryOp((x,y) -> x/y,
                                                      (x,y) -> 1/y,
                                                      (x,y) -> -x/y^2)(Dx,Dy)
Base.inv(Dx::Differential) = 1/Dx

Base.:^(Dx::Differential,y::Number) = unaryOp(Dx -> Dx^y, Dx -> y*Dx^(y-1))(Dx)
Base.:^(Dx::Differential,y::Int) = unaryOp(Dx -> Dx^y, Dx -> y*Dx^(y-1))(Dx)
Base.:^(x::Number,Dy::Differential) = unaryOp(Dy -> x^Dy, Dy -> log(x)*x^Dy)(Dy)

# Define differentiation rules for most Base and SpecialFunctions math functions

# Base.:(\ )(x::Differential,y::Number) = inv(x)*y
# Base.:(\ )(x::Number,y::Differential) = inv(x)*y
# Base.:(\ )(x::Differential,y::Differential) = inv(x)*y


function Base.atan(Dx::Union{Number,Differential}, Dy::Union{Number,Differential})
    binaryOp(atan,
             (x,y) ->  y/(x^2 + y^2),
             (x,y) -> -x/(x^2 + y^2))(Dx, Dy)
end

function Base.hypot(Dx::Union{Number,Differential}, Dy::Union{Number,Differential})
    binaryOp(hypot,
             (x,y) ->  x/hypot(x,y),
             (x,y) ->  y/hypot(x,y))(Dx,Dy)
end

function SpecialFunctions.besselj(ν, Dx::Differential)
    unaryOp(x -> besselj(ν,x), x ->(besselj(ν - 1, x) - besselj(ν + 1, x))/2)(Dx)
end
function SpecialFunctions.besseli(ν, Dx::Differential)
    unaryOp(x -> besseli(ν,x), x ->(besseli(ν - 1, x) + besseli(ν + 1, x))/2)(Dx)
end
function SpecialFunctions.bessely(ν, Dx::Differential)
    unaryOp(x -> bessely(ν,x), x ->(bessely(ν - 1, x) - bessely(ν + 1, x))/2)(Dx)
end
function SpecialFunctions.besselk(ν, Dx::Differential)
    unaryOp(x -> besselk(ν,x), x ->(besselk(ν - 1, x) + besselk(ν + 1, x))/2)(Dx)
end
function SpecialFunctions.hankelh1(ν, Dx::Differential)
    unaryOp(x -> hankelh1(ν,x), x ->(hankelh1(ν - 1, x) - hankelh1(ν + 1, x))/2)(Dx)
end

function SpecialFunctions.hankelh2(ν, Dx::Differential)
    unaryOp(x -> hankelh2(ν,x), x ->(hankelh2(ν - 1, x) - hankelh2(ν + 1, x))/2)(Dx)
end

function SpecialFunctions.polygamma(m, Dx::Differential)
    unaryOp(x -> polygamma(m,x), x -> polygamma(m + 1, x))(Dx)
end

function SpecialFunctions.beta(Dx::Union{Number,Differential}, Dy::Union{Number,Differential})
    binaryOp(beta,
             (x,y) -> beta(x,y)*(digamma(x)-digamma(x+y)),
             (x,y) -> beta(x,y)*(digamma(y)-digamma(x+y)))(Dx,Dy)
end

function SpecialFunctions.lbeta(Dx::Union{Number,Differential}, Dy::Union{Number,Differential})
    binaryOp(lbeta,
             (x,y) -> digamma(x)-digamma(x+y),
             (x,y) -> digamma(y)-digamma(x+y))(Dx,Dy)
end


for (M, f, arity) in DiffRules.diffrules()
    if arity == 1 && (M == :Base || M == :SpecialFunctions) && f ∉ [:inv, :+, :-, :abs] # [:bessely0, :besselj0, :bessely1, :besselj1]
        deriv = DiffRules.diffrule(M, f, :x)
        @eval begin
            $M.$f(Dx::Differential) = unaryOp($f, x->$deriv)(Dx)
        end
    # elseif arity == 2 && (M == :Base || M == :SpecialFunctions) && f ∉ [:+, :-, :*, :/]
    #     deriv = DiffRules.diffrule(M, f, :x, :y)
    #     @eval begin
    #         $M.$f(Dx::Differential, Dy::Differential) = binaryOp($f, (x, y)->$deriv)(Dx, Dy)
    #     end
    end
end

#---------------------------------------------------------------
#---------------------------------------------------------------
# Derivatives

function makeDiff()
    global tagCount += 1
    Differential([DTag(tagCount)],[1])
end

function extractDiff(Dx::Differential, ϵ::Differential)
    tag = (ϵ |> getTagList)[1]
    out = Differential(tagRemove(t, tag) => v for (t, v) in Dx.terms)
    if getTagList(out) == [DTag()]
        out[1]
    else
        out
    end
end
extractDiff(ex::Symbolic, ϵ::Differential) = 0

function D(f::Function)
    ϵ = makeDiff()
    x -> extractDiff(f(x + ϵ), ϵ)
end

D(f::T) where{T<:Symbolic} = promote(T)(:D, [f])
(f::Sym)(Dt::Differential) = f(Dt[1:end-1]) + D(f)(Dt[1:end-1])*Dt[end]
(ex::SymExpr)(Dx::Differential) = unaryOp(ex, D(ex))(Dx)

function D(ex::Symbolic, s::AbstractSym)
    ϵ = makeDiff()
    Dex = ex(s => s + ϵ) |> Expr |> eval
    extractDiff(Dex, ϵ)
end


function ∂(i)
    function (f)
        ϵ = makeDiff()
        arg -> extractDiff(f(UpTuple(Tuple(i==j ? arg[j]+ϵ
                                                : arg[j] for j in eachindex(arg)))),ϵ)
    end
end
# Calculus.jl:1 ends here
