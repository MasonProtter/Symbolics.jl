# types.jl

# [[file:~/Documents/Julia/scrap.org::*types.jl][types.jl:1]]
#---------------------------------------------------------------
#---------------------------------------------------------------
# Syms
abstract type Symbolic <: Number  end
abstract type AbstractSym <: Symbolic end

struct Sym <: AbstractSym
    name::Symbol
end
Sym(s::AbstractString) = Sym(Symbol(s))

function Base.show(io::IO, symbol::Sym)
    print(io, symbol.name)
end

macro sym(names...)
    out = Expr(:block)
    for name in names
	v = Sym(name)
	push!(out.args, Expr(:(=), name, v))
    end
   esc(out)
end

function Base.:(==)(x::AbstractSym, y::AbstractSym)
    (typeof(x) == typeof(y)) && (x.name == y.name)
end

Base.:(==)(x::AbstractSym, y::Number) = false
Base.:(==)(x::Number, y::AbstractSym) = false
Base.:(==)(x::AbstractSym, y) = false
Base.:(==)(x, y::AbstractSym) = false

Base.:(==)(x::AbstractSym, y::Symbol) = x.name == y
Base.:(==)(x::Symbol, y::AbstractSym) = x == y.name


Base.eval(a::AbstractSym) = eval(a.name)
Base.Symbol(s::AbstractSym) = s.name

(f::Sym)(t) = SymExpr(f, [t])
(f::Sym)(args...) = SymExpr(f, [args...])

#---------------------------------------------------------------
#---------------------------------------------------------------
# SymExprs
abstract type AbstractSymExpr <: Symbolic end
struct SymExpr <: AbstractSymExpr
    op::Symbolic
    args::Vector
end

function Base.:(==)(x::AbstractSymExpr,y::AbstractSymExpr)
    (x.op == y.op) && (length(x.args) == length(y.args)) && all(isequal.(x.args,y.args))
end

Base.:(==)(x::AbstractSymExpr, y) = false
Base.:(==)(x, y::AbstractSymExpr) = false
Base.:(==)(x::AbstractSymExpr, y::Number) = false
Base.:(==)(x::Number, y::AbstractSymExpr) = false
Base.:(==)(x::Sym, y::SymExpr) = false
Base.:(==)(x::SymExpr, y::Sym) = false


SymExpr(x::Expr) = SymExpr(Sym(x.args[1]), x.args[2:end])
SymExpr(x::SymExpr) = x
SymExpr(s::Symbol, args::Vector) = SymExpr(Sym(s), args)

function convert_for_expr(ex::AbstractSymExpr)
    if (ex.op == identity) && (ex.args |> length == 1)
	ex.args[1]
    else
	Expr(ex)
    end
end
function convert_for_expr(ex::AbstractSym)
    try
	eval(ex.name)
	ex.name
    catch e
	ex
    end
end
convert_for_expr(x) = x

function Base.Expr(x::AbstractSymExpr)
    Expr(:call, convert_for_expr(x.op), [convert_for_expr(i) for i in x.args]...)
end

Base.show(io::IO,x::AbstractSymExpr) = print(io,string(Expr(x)))

Base.eval(a::AbstractSymExpr) = eval(Expr(a))

(f::SymExpr)(t) = SymExpr(f, [t])
(f::SymExpr)(args...) = SymExpr(f, [args...])

#---------------------------------------------------------------
#---------------------------------------------------------------
# Up / Down Tuples

abstract type Structure end

SymOrSymExpr = Union{Sym, SymExpr}

struct UpTuple <: Structure
    data::Vector
end

struct DownTuple <: Structure
    data::Vector
end

function Base.show(io::IO, up::UpTuple)
    arr = up.data
    print(io, "up($(arr[1])")
    if length(arr) > 1
	for i in arr[2:end]
	    print(io, "\n   $i")
	end
    end
    print(io, ")")
end

function Base.show(io::IO, down::DownTuple)
    arr = (down.data)
    print(io, "down$(arr)")
end

(arr::UpTuple)(t) = UpTuple([i(t) for i in arr.data])
(arr::DownTuple)(t) = DownTuple([i(t) for i in arr.data])

up(data) = UpTuple(data)
down(data) = DownTuple(data)

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
mutable struct DTag
    tag::Array
    DTag(x::Array) = new(x)
    DTag(x...) = new([i for i in x] |> sort)
    DTag(x) = new([x])
end

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
mutable struct Differential
    terms::SortedDict
    function Differential(iterable)
	new(try delete!(SortedDict(iterable),DTag(-1)) catch; SortedDict(iterable) end)
    end
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

function Differential(keys::Union{Array,Tuple}, values::Union{Array,Tuple})
    Differential(try delete!(SortedDict(zip(keys,values)), DTag(-1)) catch; SortedDict(zip(keys,values)) end)
end

Base.length(t::Differential) = length(t.terms)
Base.:(==)(x::Differential,y::Differential) = x.terms == y.terms
Base.getindex(Dx::Differential, i::DTag) = Dx.terms[i]
getTagList(Dx::Differential) = [key for (key, _) in Dx.terms]


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

Base.lastindex(Dx::Differential) = length(Dx |> getTagList)

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
# types.jl:1 ends here
