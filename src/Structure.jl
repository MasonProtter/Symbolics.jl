# Structure.jl

# [[file:~/Documents/Julia/scrap.org::*Structure.jl][Structure.jl:1]]
Base.length(A::UpTuple) = length(A.data)
Base.eachindex(A::UpTuple) = eachindex(A.data)

square(arr::UpTuple) = [arr.data...]' * [arr.data...]
square(a::SymExpr) = a^2

Base.:+(A::UpTuple, b) = UpTuple([a + b for a in A.data])
Base.:+(a, B::UpTuple) = UpTuple([a + b for b in B.data])

function Base.:+(A::UpTuple, B::UpTuple)
    if length(A) == length(B)
        UpTuple([a[i] + b[i] for i in eachindex(A)])
    end
end
# Structure.jl:1 ends here
