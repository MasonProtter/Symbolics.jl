# Symbolics.jl

This is a package I'm throwing together after getting inspired by the talk [Physics in Clojure](https://www.youtube.com/watch?v=7PoajCqNKpg) which was about porting scmutils, a Scheme package accompanying the book Structure and Insterpretation of Classical Mechanics by Sussman and Wisdom. 

Examples of use:

1) Basic algebra
```julia
julia> @syms x y z t;

julia> x^2 + x^2
2 * x ^ 2

julia> x^2 - x^2
0
```

2) functional composition
```julia
julia> f(x) = x^3;

julia> g(x) = x^2;

julia> (f+g)(x)
x ^ 3 + x ^ 2

julia> (f*g)(x)
x ^ 3 * x ^ 2
```

3) (Automatic) symbolic differentiation, now with higher derivatives and no pertubration confusion!
```julia
julia> D(f+g)(x)
3 * x ^ 2 + 2x

julia> (D^2)(f+g)(x)
3 * (2x) + 2

julia> (D^3)(f+g)(x)
6
```

4) Literal functions
```julia
julia> x = LiteralFunction(:x);

julia> x(t)
x(t)

julia> D(x)(t)
D(x)(t)
```

# Near term targets
1) Primarily, I want to be able to run the following code:
```julia
@syms m, ω, t

function Γ(w)
    function (t)
        UpTuple(t, w(t), D(w)(t))
    end
end


function Lagrange_Equations(L)
    function (w)
        D(∂(2)(L)∘Γ(w)) - ∂(1)(L)∘Γ(w)
    end
end

function L(local_tuple::UpTuple)
    t, q, qdot = local_tuple
    m/2*qdot^2 - m*ω^2/2*q^2
end

x = LiteralFunction(:x)

Lagrange_Equations(x)(t)
```
and produce
```julia
m*(D^2)(x)(t) - m*ω^2*x(t)
```

In order to do this, the main things that I need to do (that I'm aware of) are:

* Fix my simplification alogirthm. There is a function `simplification_loop` which is currently exported but is not always working correctly. Its a mess and I should probably scrap it and reimplement it better.

* Properly implement UpTuples (as well as DownTuples and matrices while I'm at it) 

* Find a clean way to implement partial derivative operators. I keep thinking about this one and then being unsatisfied with and giving up. 

