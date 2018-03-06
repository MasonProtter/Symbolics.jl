push!(LOAD_PATH, "/Users/mason/Documents/Julia/Symbolics.jl/src");
using Symbolics


@syms a b c d;


macro twostep(arg)
           println("I execute at parse time. The argument is: ", arg)
           return :(println("I execute at runtime. The argument is: ", $arg))
end

ex = macroexpand( :(@twostep :(1, 2, 3)) );
@twostep :(1, 2, 3)

:(x + y).args




macro addition_to_multiplication(x)
           for i in 1:length(x.args)
                      if x.args[i] == :+
                                 x.args[i] = :*
                      end
           end
           x
end

@addition_to_multiplication 5 + 3 * 6


@showarg(x+1)



:(x + y * (1 + 2))
:(x + y*3)

using MacroTools

MacroTools.postwalk(x -> if , :(x + y * (1 + 2)))

:(x + y * (1 + 2)).args

@show(x+y)



MacroTools.postwalk(x -> x ? )
