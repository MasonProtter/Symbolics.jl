module UpDownTuples

# push!(LOAD_PATH, "/Users/mason/Documents/Julia/JuliaMath")
# using Symbolic_Dispatch
# using Simplification
# using Revise

export up, start, done, next, length, square

import Base.show
import Base.start
import Base.done
import Base.next
import Base.length
import Base.getindex
import Base.setindex!
import Simplification.expand_expression

using types


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

start(arr::UpTuple) = start(arr.data)
done(arr::UpTuple, a::Any) = done(arr.data, a::Any)
next(arr::UpTuple, a::Any) = next(arr.data, a::Any)
length(arr::UpTuple) = length(arr.data)

square(arr::UpTuple) = [arr.data...]' * [arr.data...]
square(a::Expr) = a^2

expand_expression(arr::UpTuple) = up([expand_expression(i) for i in arr.data]...)
getindex(arr::UpTuple, i::Integer) = getindex(arr.data, i)
setindex!(arr::UpTuple, value, i::Integer) = up(setindex!(arr.data, value, i))



end
