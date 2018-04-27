using Documenter, StingerGraphs

makedocs()

deploydocs(
    julia = "nightly",
    repo = "github.com/stingergraph/StingerGraphs.jl.git"
)
