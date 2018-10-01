# Symbolics.jl

This is a package I'm throwing together after getting inspired by the talk [Physics in Clojure](https://www.youtube.com/watch?v=7PoajCqNKpg) which was about porting scmutils to clojure. scmutils is a Scheme package with a very interesting and powerful computer algebra system.

My intention with Symbolics.jl is to attempt to recreate the functionality of scmutils in julia using julian syntax. The package is slowly morphing into some sort of hybrid between scmutils and Mathematica.

This package works on Julia 1.0. To add it, simply
```
pkg> add git@github.com:MasonProtter/Symbolics.jl.git
```

Examples of use:
0.7
1) Basic algebra
```julia
julia > using Symbolics

julia> @sym x y z t;

julia> x^2 + x^2
2 * x ^ 2
```

2) You can replace symbols in expressions
```julia
julia> ex = 2x + x^2
2x + x^2

julia> ex(x => y)
2y + y^2
```

3) functional composition
```julia
julia> f(x) = x^3;

julia> g(x) = x^2;

julia> f + g
(::#70) (generic function with 1 method)

julia> ans(x)
x ^ 3 + x ^ 2

julia> f * g
(::#72) (generic function with 1 method)

julia> ans(x)
x ^ 3 * x ^ 2
```

4) (Automatic) symbolic differentiation, now with higher derivatives and no pertubration confusion!
```julia
julia> D(f+g)(x)
3 * x ^ 2 + 2x

julia> (D^2)(f+g)(x)
3 * (2x) + 2

julia> (D^3)(f+g)(x)
6
```

The derivative operator, `D` is of type `Dtype <: Operator <: Function`. The reason for this is because operations on functions should sometimes behave differently than operations on differential operators. Currently the only difference is in exponentiation, such that `:^(f::Function, n) = x -> f(x)^n` whereas `:^(o::Operator,n::Integer) = x -> o(o( ... o(x)))` where the operator `o` has been applied to `x` `n` times.

5) Symbolic expressions are callable and can be differentiated
```julia
julia> D(x(t)^2 + 2x(t), t)
2 * (x)(t) * (D(x))(t) + 2 * (D(x))(t)
```

# New: Generate the Euler Lagrange Equations from a Lagrangian
We can now define a Lagrangian, say that of a simple harmonic oscillator as 
```julia
using Smybolics

@sym x m ω t

function L(local_tuple::UpTuple)
    t, q, qdot = local_tuple.data
   (0.5m)*qdot^2 - (0.5m*ω^2)*q^2
end
```
where the local_tuple is an object describing a time, posisition and velocity (ie. all the relevant phase space data). According to SICM, this data should be provided by a function `Γ(w)` where `w` defines a trajectory through space. `Γ` is defined as
```julia
function Γ(w)
    function (t)
        up(t, w(t), D(w)(t))
    end
end
```
Hence, as shown in SICM, the Euler-Lagrange condition for stationary action may be written as the functional
```julia
function Lagrange_Equations(L)
    function (w)
        D(∂(3)(L)∘Γ(w)) - ∂(2)(L)∘Γ(w)
    end
end
```
where `∂(3)` means partial derivative with respect to velocity and `∂(2)` means partial derivative with respect to position (ie. the third and second elements of the local tuple respectively). Putting this all together, we may execute
```julia
julia> Lagrange_Equations(L)(x)(t)
(D(D(x)))(t) * m + (x)(t) * m * ω ^ 2
```
which when set equal to zero is the equation of motion for a simple harmonic oscillator, generated in pure Julia code code symbolically!







