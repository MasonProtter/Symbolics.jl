# tests

# [[file:~/Documents/Julia/scrap.org::*tests][tests:1]]
testfiles = (
    "algebra.jl",
    "derivatives.jl",
    "structures.jl",
    "eulerlagrange.jl",
    "latex.jl",
    "newnumbers.jl",
    )

for file in testfiles
    include(file)
end
# tests:1 ends here
