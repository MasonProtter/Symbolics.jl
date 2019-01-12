Base.:(==)(x::A, y::B) where {A<:Symbolic,B<:Symbolic} = false
Base.promote(x::A, y::B) where {A<:Symbolic,B<:Symbolic} =
    (SymExpr(:identity, [x]), SymExpr(:identity, [y]))

"""
    @new_number NumberType (a::NumberType{T}, b::NumberType{U}) where {T,U} begin
        # Implementation of a == b
    end

Register a custom `NumberType<:Symbolic` as a number that can be used
for symbolic manipulation. `@new_number` will define a few promotion
rules as well as a comparison function between two objects of the type
`NumberType`. The second argument to the macro, the type signature,
need not be dependent on type parameters, but is possible to implement
a comparison operator that considers the type parameters as well.
"""
macro new_number(type_name, comp_params, compare)
    # Generate the method signature for Base.:(==)
    Base_isequal = Expr(:call, Expr(Symbol("."), :Base, :(:(==))))
    signature,args = if comp_params.head == :where
        # Type parameters requested
        Expr(:where, Base_isequal, comp_params.args[2:end]...),comp_params.args[1].args
    else
        # No type parameters
        Base_isequal,comp_params.args
    end
    append!(Base_isequal.args, args)
    # Associate the method signature with the actual implementation in
    # `compare`.
    def = Expr(:(=), signature, compare)

    quote
        # Comparison with objects of the same type
        $(esc(def))

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
