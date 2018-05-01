#---------------------------------------------------------------
#---------------------------------------------------------------
# Syms
using AutoHashEquals
@auto_hash_equals struct Sym
    name::Symbol
end

function Base.show(io::IO, symbol::Sym)
    print(io, symbol.name)
end

macro syms(names...)
    out = Expr(:block)
    for name in names
        v = Sym(name)
        push!(out.args, Expr(:(=), name, v))
    end
   esc(out)
end

Base.:(==)(x::Sym, y::Real) = false
Base.:(==)(x::Real, y::Sym) = false
Base.:(==)(x::Sym, y::Sym) = x.name == y.name ? true : false

#---------------------------------------------------------------
#---------------------------------------------------------------
# SymExprs
struct SymExpr
    op::Function
    args::Vector
end

function Base.:(==)(x::SymExpr,y::SymExpr)
    x.op == y.op && length(x.args) == length(y.args) && all(isequal.(x.args,y.args))
end

Base.:(==)(x::SymExpr,y::Number) = false
Base.:(==)(x::Number,y::SymExpr) = false
Base.:(==)(x::SymExpr,y::Void) = false
Base.:(==)(x::Void,y::SymExpr) = false
Base.:(==)(x::Sym,y::SymExpr) = y == SymExpr(identity,x)
Base.:(==)(x::SymExpr,y::Sym) = x == SymExpr(identity,y)

SymExpr(x::Expr) = SymExpr(eval(x.args[1]), x.args[2:end])
SymExpr(x::SymExpr) = x
SymExpr(f::Function, arg::Union{Sym, Number}) = SymExpr(f, [arg])
SymExpr(f::Sym, arg::Union{Sym, Number}) = SymExpr(eval(f.name), [arg])
SymExpr(x::Vector) = SymExpr(x[1], x[2:end])
SymExpr(f::Sym, args::Vector) = SymExpr(eval(f.name), args)

Base.Expr(x::SymExpr) = Expr(:call, Symbol(x.op), [i isa SymExpr ? Expr(i) :
                                                   i isa Sym ? i.name :
                                                   i
                                                   for i in x.args]...)

Base.show(io::IO,x::SymExpr) = print(io,string(Expr(x)))

Base.eval(a::SymExpr) = eval(Expr(a))

# function to_Expr(a::SymExpr)
#     Expr(a.head, [i isa SymExpr ? to_Expr(i) :
#                   i isa Sym ? i.name :
#                   i for i in a.args]...)
# end

# function Base.show(io::IO, symexpr::SymExpr)
#     print(io, string(symexpr.expr))
# end




Mathy = Union{Number, Sym, SymExpr}

#---------------------------------------------------------------
#---------------------------------------------------------------
# Literal Functions

struct LiteralFunction <: Function
    name::Union{Expr, Symbol, Sym}
end

function Base.show(io::IO, f::LiteralFunction)
    print(io, f.name)
end

(f::LiteralFunction)(t) = :($(f.name)($t))

#---------------------------------------------------------------
#---------------------------------------------------------------
# Up / Down Tuples

abstract type Structure end

struct UpTuple <: Structure
    data
end

struct DownTuple <: Structure
    data
end

function Base.show(io::IO, up::UpTuple)
    arr = [(up.data)...]
    print(io, "up($(arr[1])")
    if length(arr) > 1
        for i in arr[2:end]
            print(io, ", $i")
        end
    end
    print(io, ")")
end

(arr::UpTuple)(t) = up([i(t) for i in arr.data]...)

up(data...) = UpTuple(data)

Base.start(arr::UpTuple) = start(arr.data)
Base.done(arr::UpTuple, a::Any) = done(arr.data, a::Any)
Base.next(arr::UpTuple, a::Any) = next(arr.data, a::Any)
Base.length(arr::UpTuple) = length(arr.data)

square(arr::UpTuple) = [arr.data...]' * [arr.data...]
square(a::SymExpr) = a^2

expand_expression(arr::UpTuple) = up([expand_expression(i) for i in arr.data]...)
Base.getindex(arr::UpTuple, i::Integer) = getindex(arr.data, i)
Base.setindex!(arr::UpTuple, value, i::Integer) = up(setindex!(arr.data, value, i))


#---------------------------------------------------------------
#---------------------------------------------------------------
# Operators

abstract type Operator <: Function end

struct Dtype <: Operator end
const D = Dtype()
const ∂ = Dtype()


#---------------------------------------------------------------
#---------------------------------------------------------------
# Differential Tags
type DTag
    tag::Array
end

DTag(x) = DTag([x])

DTag(x...) = DTag([i for i in x] |> sort)

Base.length(t::DTag) = length(t.tag)
Base.:(==)(x::DTag,y::DTag) = x.tag == y.tag
Base.getindex(t::DTag, i::Int) = (t.tag)[i]

function Base.isless(t1::DTag,t2::DTag)
    if length(t1) == length(t2)
        for i in 1:length(t1)
            if t1[i] >= t2[i]
                return false
            end
        end
        t1 == t2 ? (return false ) : (return true)
    elseif length(t1) < length(t2)
        true
    else
        false
    end
end

function hasDuplicates(arr)
    for i in 1:(length(arr)-1)
        for j in (i+1):length(arr)
            if arr[i] == arr[j]
                return true
            end
        end
    end
    false
end

Base.setdiff(t1::DTag, t2::DTag) = DTag(setdiff(t1.tag, t2.tag) |> sort)
Base.intersect(t1::DTag, t2::DTag) = DTag(intersect(t1.tag, t2.tag) |> sort)

tagRemove(t1::DTag, t2::DTag) = intersect(t1,t2) != DTag() ? setdiff(t1,t2) : DTag(-1)
t1 = DTag([1,2])
t2 = DTag([1])


#---------------------------------------------------------------
#---------------------------------------------------------------
# Differentials
type Differential
    terms::SortedDict
end

function printEpsilons(t::DTag)
    str = ""
    for i in t.tag
        str = str*"ϵ$i"
    end
    str
end

function Base.show(io::IO, diff::Differential)
    str = ""
    for (tag, term) in diff.terms
        if tag == DTag()
            str = str*"$(term)$(printEpsilons(tag))"
        elseif str == ""
            str = str*"($(term))$(printEpsilons(tag))"
        else
            str = str*" + ($(term))$(printEpsilons(tag))"
        end
    end
    print(io, str)
end

function Differential(iterable)
    Differential(try delete!(SortedDict(iterable),DTag(-1)) catch SortedDict(iterable) end)
end

function Differential(keys::Union{Array,Tuple}, values::Union{Array,Tuple})
    Differential(try delete!(SortedDict(zip(keys,values)), DTag(-1)) catch SortedDict(zip(keys,values)) end)
end

Base.length(t::Differential) = length(t.terms)
Base.:(==)(x::Differential,y::Differential) = x.terms == y.terms
Base.getindex(t::Differential, i::DTag) = (t.terms)[i]
getTagList(Dx::Differential) = [key for (key, _) in Dx.terms]

Base.getindex(Dx::Differential, i::DTag) = Dx.terms[i]

function Base.getindex(Dx::Differential, i::Int)
    key = getTagList(Dx)[i]
    key == DTag() ? Dx.terms[key] : Differential(key => Dx.terms[key])
end

function Base.getindex(Dx::Differential, i::UnitRange)
    keys = getTagList(Dx)[i]
    if length(i) == 1
        out = (Dx.terms)[keys...]
    else
        Differential(k => Dx.terms[k] for k in keys)
    end
end

Base.endof(Dx::Differential) = length(Dx |> getTagList)

lastTag(Dx::Differential) = getTagList(Dx)[end]

function tagUnion(x::Differential, y::Differential)
    vcat(x |> getTagList, y |> getTagList) |> sort |> fastuniq
end

function fastuniq(v)
  v1 = Vector{eltype(v)}()
  if length(v)>0
    laste = v[1]
    push!(v1,laste)
    for e in v
      if e != laste
        laste = e
        push!(v1,laste)
      end
    end
  end
  return v1
end

tagCount = 0
