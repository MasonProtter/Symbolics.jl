using LaTeXStrings
using Printf

# * User flags

ABBREVIATE_POWER_OF_NEGATIVE_UNITY=false
ADVANCE_DELIMITERS=true

"""
    abbreviate_power_of_negative_unity(flag)

If `flag` is `true`, powers of `(-1)` will be printed as `(-)ᵖ`, if
`false` as `(-1)ᵖ`.
"""
function abbreviate_power_of_negative_unity(flag::Bool)
    global ABBREVIATE_POWER_OF_NEGATIVE_UNITY
    ABBREVIATE_POWER_OF_NEGATIVE_UNITY=flag
end

"""
    advance_delimiters(flag)

If `flag` is `true`, nested delimiters will alternate as `{x + [y + (z
+ w)]}` to highlight the level of nesting; if `false`, the delimiters
will not alternate: `(x + [y + (z + w)])`.
"""
function advance_delimiters(flag::Bool)
    global ADVANCE_DELIMITERS
    ADVANCE_DELIMITERS=flag
end

# * LaTeX conversion

# ** Numbers

function latex(sym::Symbolic)
    sym_str = replace(replace("$(sym)", "{"=>"\\{"), "}"=>"\\}")
    "\\textrm{$(sym_str)}",0
end
latex(s::Real) = "$(s)",0


function base_exp(v::T) where {T<:AbstractFloat}
    v == zero(T) && return (zero(T),0)
    r = log10(abs(v))
    e = floor(Int,r)
    b = sign(v)*T(10)^(r-e)
    b,e
end

function latex(s::AbstractFloat)
    b,e = base_exp(s)
    if abs(e) < 3
        @sprintf("%0.10g", s)
    else
        "$b\\times10^{$e}"
    end,0
end

function latex(z::Complex{T}) where T
    a,b = real(z),imag(z)
    la,lb = latex(a),latex(b)
    sla,slb = if T == Bool
        "",""
    else
        la[1],lb[1]
    end
    if a == zero(T)
        slb * "\\mathrm{i}"
    elseif b == zero(T)
        sla
    else
        sla * (b < 0 ? "" : "+") * slb * "\\mathrm{i}"
    end,max(la[2],lb[2])
end
latex(s::Sym) = "$(s)",0

# ** Operators

LaTeX_operators = Dict(:(+) => "+",
                       :(-) => "-",
                       :(*) => "",
                       :(/) => "/",
                       :(%) => "\\mod", # rem(::Symbolic) not implemented
                       :log => "\\ln",
                       :log10 => "\\log_{10}",
                       :log2 => "\\log_2",
                       :asin => "\\arcsin",
                       :asinh => "\\operatorname{arcsinh}",
                       :acos => "\\arccos",
                       :acosh => "\\operatorname{arccosh}",
                       :atan => "\\arctan",
                       :atanh => "\\operatorname{arctanh}")

# These functions have the same names in LaTeX
LaTeX_functions = [:sin, :sinh,
                   :cos, :cosh,
                   :tan, :tanh,
                   :exp,
                   :min, :max,
                   :mod,
                   :sqrt]

function latex_op(op::Sym)
    if op.name in keys(LaTeX_operators)
        LaTeX_operators[op.name]
    elseif op.name in LaTeX_functions
        "\\$(op.name)"
    else
        "$(op)"
    end
end

latex_op(op) = latex(op)

# ** Delimiters

get_next_delim(max_delim) =
    [("(",")"), ("[","]"), ("\\{", "\\}")][mod(max_delim,3)+1]

function delimit(val, max_delim, doit::Bool=true)
    !doit && return (val,max_delim)
    a,b = get_next_delim(max_delim)
    "\\left$(a)$(val)\\right$(b)", max_delim + (ADVANCE_DELIMITERS ? 1 : 0)
end

should_be_delimited(::Sym) = false
should_be_delimited(::Number) = true
should_be_delimited(r::Real) = isnegated(r)
should_be_delimited(v::Vector) = length(v) > 1 || should_be_delimited(v[1])

brace(s::String) = "{$(s)}"

# ** Arguments

function latex_arg(arg,should_delimit::Bool)
    larg = latex(arg)
    if should_delimit && (arg isa SymExpr && arg.op.name ∈ [:(+)] ||
                         arg isa Complex ||
                         arg isa Real && arg < 0)
        delimit(larg...)
    else
        larg
    end
end

latex_args(args::Vector,should_delimit::Bool) =
    map(arg -> latex_arg(arg, should_delimit), args)

latex_args(expr::SymExpr,should_delimit::Bool) =
    latex_args(expr.args, should_delimit)

latex_args(s::Number,::Bool) = [latex_arg(s, false)]

# ** Expressions

function latex(expr::SymExpr)
    op = expr.op
    lop = latex_op(op)
    # The arguments need only be wrapped in delimiters for products
    # and powers.
    largs = latex_args(expr.args, op.name ∈ [:(*), :(^)])
    max_delim = maximum(last.(largs))

    if op.name == :(+)
        S = first(largs[1])
        for a in first.(largs[2:end])
            S *= first(lstrip(a, ['{'])) == '-' ? "" : "+"
            S *= a
        end
        S,max_delim
    elseif op.name == :(^)
        arg1 = expr.args[1]
        earg2 = latex_arg(expr.args[2], false)
        earg2s = "^{$(earg2[1])}"
        # If the user has requested thus, (-1)^z will be printed as (-)^z
        if ABBREVIATE_POWER_OF_NEGATIVE_UNITY &&
            arg1 isa Number && !(arg1 isa SymExpr) && arg1 isa Real && arg1 == -1
            "(-)$(earg2s)",max((ADVANCE_DELIMITERS ? 1 : 0),earg2[2])
        elseif arg1 isa SymExpr && arg1.op.name ∉ [:(+), :(*), :(^), :sqrt]
            larg1 = latex_args(arg1.args,false)
            max_delim = max(maximum(last.(larg1)), earg2[2])
            slarg1 = join(first.(larg1), ",")
            if should_be_delimited(arg1.args)
                slarg1,max_delim = delimit(slarg1,max_delim)
            end
            "$(latex_op(arg1.op))$(earg2s)$(slarg1)",max_delim
        else
            "$(largs[1][1])$(earg2s)",max(largs[1][2],earg2[2])
        end
    elseif op.name == :(*)
        i = findfirst(isequal(-1), expr.args)
        isneg = i !== nothing
        expr = !isneg ? expr : prod(expr.args[vcat(1:i-1,i+1:length(expr.args))])

        num = numerator(expr)
        den = denominator(expr)

        max_delim = 0
        # If there is a factor -1, represent that as a prefactor -.
        (isneg ? "-" : "")*if den == 1
            # Only numerator
            if num isa SymExpr && num.op.name == :(*)
                nlargs = latex_args(num, true)
                max_delim = maximum(last.(nlargs))
                join(first.(nlargs),"")
            else
                # Dropping a possible -1 factor may have yielded an
                # expression that is not a multiplication anymore.
                nlarg,max_delim = delimit(latex(num)...,
                                          isneg && should_be_delimited(num))
                nlarg
            end
        else
            # Fraction
            lnum = latex(num)
            lden = latex(den)
            max_delim = max(lnum[2],lden[2])
            "\\frac{$(lnum[1])}{$(lden[1])}"
        end,max_delim
    else
        # Any other function
        slargs = join(first.(largs), ",")

        dargs,max_delim = if op.name != :sqrt && (length(largs) > 1 ||
                                                 should_be_delimited(first(expr.args)))
            delimit(slargs, max_delim)
        else
            brace(slargs),max_delim
        end

        "$(lop)$(dargs)",max_delim
    end
end

# **nothing
latex(::Nothing) = "",0

# **matrices
function latex(A::AbstractMatrix)
    ret = "\\begin{pmatrix}\n"
    for k = 1:size(A,1)-1
        for j = 1:size(A,2)-1
            ret *= latex(A[k,j])[1] * " & "
        end
        ret *= latex(A[k,end])[1] * " \\\\\n"
    end
    for j = 1:size(A,2)-1
        ret *= latex(A[end,j])[1] * " & "
    end
    ret *= latex(A[end,end])[1]
    ret *= "\n\\end{pmatrix}"

    ret, 0
end


# * Convert to LaTeXString, display

Base.convert(::Type{LaTeXString}, s::S) where {S<:Symbolic} =
    latexstring("\$$(latex(s)[1])\$")

Base.show(io::IO, ::MIME"text/latex", s::S) where {S<:Symbolic} =
    show(io, "text/latex", convert(LaTeXString, s))
