push!(LOAD_PATH, "/Users/mason/Documents/Julia/JuliaMath")

using Revise
using ForwardDiff
# using Derivatives
using Symbolic_Dispatch
using Simplification
using Sym_Auto_Diff
using UpDownTuples








D(x -> x * e^x + 5*log(x))(:t)


using MacroTools
MacroTools.postwalk(x -> @show(x), sin(:t ^2 + 1 + 1 ))


function Γ(w)
     function (t)
          [t, w(t), D(w)(t)]
     end
end

function Lagrange_Equations(L)
    w -> D((∂(L,3)∘(Γ(w)))) - ∂(L,2)∘Γ(w)
end


L_free(X) = 1/2*X[3]^2


Lagrange_Equations(L_free)(w)(0)


sin(:x)

f(x...) =
