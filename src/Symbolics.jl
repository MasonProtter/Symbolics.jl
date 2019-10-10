module Symbolics

using MacroTools: MacroTools, postwalk, @capture
using SpecialFunctions: SpecialFunctions
using Espresso: Espresso, rewrite_all

# struct Predicate
#     pred::Expr
# end

export Sym


struct Sym
    x
    preds::Set{Expr}
    Sym(x, preds) = new(x, preds)
    Sym(x, pred::Expr) = new(x, Set(pred))
    Sym(x::Sym)        = x
    Sym(x)             = new(x, Set())
end
Sym(x::Symbol) = Sym(x, Set([:($x::Real)]))

unwrap(s::Sym)           = s.x, s.preds
unwrap(s1::Sym, s2::Sym) = s1.x, s2.x, (s1.preds ∪ s2.preds)
unwrap(s1::Sym, s2)      = s1.x, s2, (s1.preds)
unwrap(s1, s2::Sym)      = s1, s2.x, (s2.preds)
unwrap(x)                = x

#Base.promote_rule(::Type{Sym}, ::Type{Sym}) = Sym{promote_type(T, U)}
#Base.promote_rule(::Type{Sym}, ::Type{U})   where {U} = Sym{promote_type(T, U)}

Base.:(==)(a::Sym, b::Sym) = a.x == b.x

Base.zero(::Type{Sym}) where {T} = Sym(0)
Base.one( ::Type{Sym}) where {T} = Sym(1)

function Base.show(io::IO, s::Sym) 
    str = repr(s.x)
    if s.x isa Union{Symbol, Expr}
        str = str[2:end]
    end
    preds = collect(s.preds)
    print(io, str, " where ", preds[1])
    for pred in preds[2:end]
        print(io, ", ", pred)
    end
end


function merge_preds(a::Sym, b::Sym)
    ax, ap = a.x, a.preds
    bx, bp = b.x, b.preds
    p = ap ∪ bp
    Sym(ax, p), Sym(bx, p)
end



macro sym(ex_in)
    names = Symbol[]
    ex = postwalk(ex_in) do x
        if x isa Expr && x.head == :$ && length(x.args) == 1 && x.args[1] isa Symbol
            s = x.args[1]
            push!(names, s)
            :($s)
        else
            x
        end
    end |> Meta.quot
    preds = (length(names) == 1 ? :($(names[1]).preds) : foldl((s1, s2) -> :($s1.preds ∪ $s2.preds), names))

    exgen = gensym()
    namesgen = exgen = gensym()
    valsgen = gensym()
    ntgen = gensym()
    quote
        local $namesgen = $names
        local $valsgen = [$(names...)]
        local $ntgen = Dict{Symbol, Sym}($namesgen[i] => $valsgen[i] for i in 1:$(length(names)))
        Sym(Symbolics.postwalk(x -> x ∈ $namesgen ? $ntgen[x].x : x, $ex) , $preds)
    end |> esc
end



#-----------------------------------------
# Addition

Base.:(+)(a::Sym) = a

Base.:(+)(a::Sym, b::Sym) = _add(a, b)
Base.:(+)(a,      b::Sym) = _add(a, b)
Base.:(+)(a::Sym, b     ) = _add(a, b)

function _add(a, b)::Sym
    ax, bx, preds = unwrap(a, b)
    # if a == b
    #     2*a
    # elseif a == 0
    #     b
    # elseif b == 0
    #     a
    # elseif a == -b
    #     Sym(0)
    # else
    Sym(:($ax + $bx), preds)
    # end
end

#-----------------------------------------
# Subtraction

function Base.:(-)(a::Sym)
    # if a.x isa Expr && length(a.x.args) == 2 && a.x.args[1] == :-
    #     Sym(a.x.args[2], a.preds)
    # else
        Sym(:(-$(a.x)), a.preds)
    # end
end

function Base.:(-)(a::Sym, b::Sym)
    # a, b, preds = unwrap(a, b)
    a == b ? Sym(0, preds) : a + -(b)
end

Base.:(-)(a, b::Sym) = a + -(b)
Base.:(-)(a::Sym, b) = a + -(b)

#-----------------------------------------
# Multiplication

function _mul(a, b)::Sym
    ax, bx, preds = unwrap(a, b)
    # if a == b
    #     Sym(:($ax^2), preds) 
    # elseif a == 1
    #     b
    # elseif b == 1
    #     a
    # else
        Sym(:($ax * $bx), preds)
    # end
end

Base.:(*)(a::Sym, b::Sym) = _mul(a, b)
Base.:(*)(a,      b::Sym) = _mul(a, b)
Base.:(*)(a::Sym, b     ) = _mul(a, b)

#-----------------------------------------
# Division

inv(a::Sym) = Sym(:(inv($(a.x))), a.preds)

function _div(a, b)::Sym
    ax, bx, preds = unwrap(a, b)
    # if a == b
    #     Sym(1)
    # elseif b == 1
    #     a
    # else
    Sym(:($ax /$bx), preds)
    # end
end

Base.:(/)(a::Sym, b::Sym) = a * inv(b)#_div(a, b)
Base.:(/)(a,      b::Sym) = a * inv(b)#_div(a, b)
Base.:(/)(a::Sym, b     ) = a * inv(Sym(b))#_div(a, b)

#-----------------------------------------
# Exponents

function _pow(a, b)::Sym
    ax, bx, preds = unwrap(a, b)
    # if a == 1
    #     Sym(1)
    # elseif b == 1
    #     a
    # elseif b == 0
    #     Sym(1)
    # else
    Sym(:($ax ^ $bx), preds)
    # end
end

Base.:(^)(a::Sym, b::Sym) = _pow(a, b)
Base.:(^)(a,      b::Sym) = _pow(a, b)
Base.:(^)(a::Sym, b     ) = _pow(a, b)


for f in [:exp, :log, :sqrt, :cbrt,
          :sin, :asin, :cos, :acos, :tan, :atan,
          :sinh, :asinh, :cosh, :acosh, :tanh, :atanh]
    @eval Base.$f(a::Sym) = Sym(:($(Symbol($f))($(a.x))), a.preds)
end



#------------------------------------------------------------
#------------------------------------------------------------
# Simplification
#------------------------------------------------------------
#------------------------------------------------------------

function simplify(s::Sym; maxcount=1000)
    s′ = _simplify(s)
    counter = 1
    while s′ != s && counter < maxcount
        s  = _simplify(s′)
        s′ = _simplify(s)
        counter += 1
    end
    s′
end

function _simplify(s::Sym)
    Sym(postwalk(ex -> apply_rules(ex, s.preds), s.x), s.preds)
end

apply_identities(s, preds) = s


function addition_identities(ex::Expr, preds)
    rewrite_all(ex, [:(_x - _x) => :(0),
                     :(_x + _x) => :(2*_x),
                     :(_x + -_x) => :(0),
                     :(-_x + _x) => :(0),
                     :(_a*_x + _b*_x) => :((_a + _b)*_x),
                     :(_x*_a + _b*_x) => :((_a + _b)*_x),
                     :(_a*_x + _b*_x) => :((_a + _b)*_x),
                     :(_x*_a + _x*_b) => :((_a + _b)*_x),
                     :((_x + _y) + _z) => :(+(_x, _y, _z)),
                     :(_x + (_y + _z)) => :(+(_x, _y, _z)),
                     ])
end

const rules = Function[addition_identities]

apply_rules(s, preds) = s
function apply_rules(ex::Expr, preds::Set)
    ex
    for rule in rules
        ex = rule(ex, preds)
    end
    ex
end




end
