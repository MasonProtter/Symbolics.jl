# Structure.jl

# [[file:~/Documents/Julia/scrap.org::*Structure.jl][Structure.jl:1]]
Base.length(A::UpTuple) = length(A.data)
Base.eachindex(A::UpTuple) = eachindex(A.data)

square(arr::UpTuple) = [arr.data...]' * [arr.data...]
square(a::SymExpr) = a^2

# addition and substraction
for op in [:+, :-]
    @eval Base.$op(x::UpTuple, y::UpTuple) = UpTuple($op(x.data, y.data))
    @eval Base.$op(A::UpTuple, b) = UpTuple([$op(a, b) for a in A.data])
    @eval Base.$op(a, B::UpTuple) = UpTuple([$op(a, b) for b in B.data])
end

Base.:(==)(x::UpTuple, y::UpTuple) = x.data == y.data

Base.iterate(x::UpTuple) = iterate(x.data)
Base.iterate(x::UpTuple, n::Int64) = iterate(x.data, n)

# Structure.jl:1 ends here
