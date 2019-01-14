using Symbolics, Test
import Symbolics: latex

@testset "LaTeX rendering" begin
    @sym x y z

    Symbolics.abbreviate_power_of_negative_unity(true)
    @test latex((-1)^x) == ("(-)^{x}", 1)

    Symbolics.abbreviate_power_of_negative_unity(false)
    @test latex((-1)^x) == ("\\left(-1\\right)^{x}", 1)

    Symbolics.abbreviate_power_of_negative_unity(true)
    f=sin(x^3)
    @test latex(f) == ("\\sin\\left(x^{3}\\right)", 1)
    g′=x/(-z)
    @test latex(g′) == ("\\frac{x}{-z}", 0)
    g=x/-sin(z)
    @test latex(g) == ("\\frac{x}{-\\left(\\sin{z}\\right)}", 1)
    @test latex(x/((x+y+z)^4)) == ("\\frac{x}{\\left(x+y+z\\right)^{4}}", 1)
    @test latex(x/(sin(z)^4)) == ("\\frac{x}{\\sin^{4}z}", 0)
    @test latex(x/(sin(y+z)^4)) == ("\\frac{x}{\\sin^{4}\\left(y+z\\right)}", 1)
    @test latex(x/(sin(y+z))) == ("\\frac{x}{\\sin\\left(y+z\\right)}", 1)
    @test latex(x/(sin(z)^(y+x))) == ("\\frac{x}{\\sin^{y+x}z}", 0)
    @test latex(x + im) == ("x+\\mathrm{i}", 0)
    h=cos(f+g)
    @test latex(h) == ("\\cos\\left[\\sin\\left(x^{3}\\right)+\\frac{x}{-\\left(\\sin{z}\\right)}\\right]", 2)

    Symbolics.advance_delimiters(false)
    @test latex(cos((-1)^x+sin(h))) == ("\\cos\\left((-)^{x}+\\sin\\left(\\cos\\left(\\sin\\left(x^{3}\\right)+\\frac{x}{-\\left(\\sin{z}\\right)}\\right)\\right)\\right)", 0)

    Symbolics.advance_delimiters(true)
    @test latex(cos((-1)^x+sin(h))) == ("\\cos\\left((-)^{x}+\\sin\\left\\{\\cos\\left[\\sin\\left(x^{3}\\right)+\\frac{x}{-\\left(\\sin{z}\\right)}\\right]\\right\\}\\right)", 4)
    @test latex(cos((-1)^x+f)) == ("\\cos\\left[(-)^{x}+\\sin\\left(x^{3}\\right)\\right]", 2)

    @test latex(cos((-1)^(2x+y*(z+cos(x)))+sin(h))) == ("\\cos\\left((-)^{2x+y\\left(z+\\cos{x}\\right)}+\\sin\\left\\{\\cos\\left[\\sin\\left(x^{3}\\right)+\\frac{x}{-\\left(\\sin{z}\\right)}\\right]\\right\\}\\right)", 4)
    @test latex(cos((-1)^(2x+y*(z+cos(x)))+f)) == ("\\cos\\left[(-)^{2x+y\\left(z+\\cos{x}\\right)}+\\sin\\left(x^{3}\\right)\\right]", 2)
    @test latex(x-y-z+x^(2y+4z*(y+x))) == ("-\\left(y+z\\right)+x+x^{2y+4z\\left(y+x\\right)}", 1)
    @test latex(asinh(x+sin(y))) == ("\\operatorname{arcsinh}\\left(x+\\sin{y}\\right)", 1)
    @test latex(log10(x)+log(x)+log2(x)) == ("\\log_{10}{x}+\\ln{x}+\\log_2{x}", 0)
    @test latex(√x) == ("\\sqrt{x}", 0)
    @test latex(√(x+y)) == ("\\sqrt{x+y}", 0)
    @test latex(sin(x/y)) == ("\\sin\\left(\\frac{x}{y}\\right)", 1)
    @test latex(cos(sin(x/y))) == ("\\cos\\left[\\sin\\left(\\frac{x}{y}\\right)\\right]", 2)
    @test latex(sin(-x)) == ("\\sin\\left(-x\\right)", 1)
    @test latex(exp(-x/y)) == ("\\exp\\left(-\\frac{x}{y}\\right)", 1)
    @test latex(exp(x/-y)) == ("\\exp\\left(\\frac{x}{-y}\\right)", 1)

    @test latex(1e-17x) == ("1.0\\times10^{-17}x",0)
end
