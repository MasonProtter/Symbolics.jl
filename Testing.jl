push!(LOAD_PATH, "/Users/mason/Documents/Julia/JuliaMath");
using Sym_Auto_Diff

x = 1 + ϵ
x.tag

Sym_Auto_Diff.iterate_tag()

y= 2 + ϵ
y.tag

(y*x).tag

y = 1 + im
imag(y)

using ForwardDiff


D(f) = t -> ForwardDiff.derivative(f, t)

D(D(x -> x^2))(5100)



