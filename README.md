# Symbolics.jl

This is a package I'm throwing together after getting inspired by the talk [Physics in Clojure](https://www.youtube.com/watch?v=7PoajCqNKpg) which was about porting scmutils, a Scheme package accompanying the book Structure and Insterpretation of Classical Mechanics by Sussman and Wisdom. 

Examples of use: 
```
julia> @syms x y z;

julia> x^2 + x^2
2 * x ^ 2

julia> x^2 - x^2
0


julia> f(x) = x^3 + 4*x^2 + 1;

julia> f(x)
x ^ 3 + 4 * x ^ 2 + 1

julia> D(f)(x)
3 * x ^ 2 + 8 * x
```
