Base.:(==)(x::A, y::B) where {A<:Symbolic,B<:Symbolic} = false
Base.promote(x::A, y::B) where {A<:Symbolic,B<:Symbolic} =
    (SymExpr(:identity, [x]), SymExpr(:identity, [y]))

# Thanks to Alex Arslan
hasusermethod(func, ::Type{T}) where T =
    hasmethod(func, Tuple{T,T}) &&
    Base.tuple_type_tail(which(func, Tuple{T,T}).sig) == Tuple{T,T}

"""
    @new_number NumberType

Register a custom `NumberType<:Symbolic` as a number that can be used
for symbolic manipulation. `@new_number` will define a few promotion
rules as well as a comparison function between two objects of the type
`NumberType`, and a `Base.hash(::NumberType)`, if there are no
pre-existing (user-defined) implementations. These default
implementations will compare/hash `NumberType` field-by-field. If
`NumberType` is parametrized and you need to dispatch the
comparison/hash on the parameters, you have to define these functions
before calling the `@new_number` macro.
"""
macro new_number(type_name)
    @isdefined(type_name) || error("No such type $(type_name)")

    quote
        local T = $(esc(type_name))
        isstructtype(T) || error("$(type_name) does not designate a type")

        local ftnames = fieldnames(T)

        (hasusermethod(isequal, T) || hasusermethod(==, T)) ||
            eval(AutoHashEquals.auto_equals($(esc(type_name)), ftnames))

        hasusermethod(hash, T) ||
            eval(AutoHashEquals.auto_hash($(esc(type_name)), ftnames))

        # Comparison with other number types are false by default
        Base.:(==)(x::$(esc(type_name)), y::N) where {N<:Union{Real,Complex}} = false
        Base.:(==)(x::N, y::$(esc(type_name))) where {N<:Union{Real,Complex}} = false
        Base.:(==)(x::$(esc(type_name)), y::Sym) = false
        Base.:(==)(x::Sym, y::$(esc(type_name))) = false
        Base.:(==)(x::$(esc(type_name)), y::SymExpr) = false
        Base.:(==)(x::SymExpr, y::$(esc(type_name))) = false

        # Promotion rules
        Base.promote(::Type{<:$(esc(type_name))}) = SymExpr

        Base.promote(x::TT, y::SymExpr) where {TT<:$(esc(type_name))} =
            (SymExpr(:identity, [x]), y)
        Base.promote(x::SymExpr, y::TT) where {TT<:$(esc(type_name))} =
            (x, SymExpr(:identity, [y]))
    end
end
