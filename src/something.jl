using LaTeXStrings

L"""x \rightarrow x+1"""
f(x) = x+1


L"""x \rightarrow x + 2"""

"""
```math
x = x + 1
```
"""
f(x::Integer) = x+2


"""
```math
f(a) = \\frac{1}{2πi} \\int_\\gamma dz \\frac{f(z)}{z-a}
```

hello world
"""
h(x) = x+1

?h(x)

@doc h


function ψ(x)
    if 0 <= x < 0.25
        sin(40(x))
    elseif 0.25 <= x < 0.75
        sin(40*0.25)*cosh(10(x-1/2))/2
    elseif 0.75 <= x < 1
        sin(40(1-x))
    else
        0
    end
end

x = linspace(-0.25,1.25,1000)

using Plots
plot(x, ψ.(x).^2)



ψ.(x)
