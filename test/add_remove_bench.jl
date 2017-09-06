using StingerGraphs
using Base.Test

function generate!(edges, numvertices::Integer, numedges::Integer)
    for i in 1:numedges
        src, dst = rand(0:numvertices-1), rand(0:numvertices-1)
        edges[:,i] = [0, src, dst, 1, 0]
    end
end

function bench(numvertices, numedges)
    info("Allocating a STINGER")
    s = Stinger()
    edges = zeros(Int64, 5, numedges)
    info("Generating the edges")
    @time generate!(edges, numvertices, numedges)
    info("Inserting $(size(edges,2)) edges")
    @time insert_edges!(s, edges, numedges)
    @test consistency_check(s, numvertices) == true
    removals = edges[:,randperm(numedges)]
    removals = unique(removals, 2)
    @show size(removals)
    info("Removing 1/8 of the edges")
    @time remove_edges!(s, removals, ceil(Int, numedges/8))
    @test consistency_check(s, numvertices) == true
    return s, edges, removals
end

info("Setting STINGER Parameters")
ENV["STINGER_MAX_MEMSIZE"] = 20000000
info("small run to precompile")
bench(100, 100)
info("real benchmark: nv=1000,ne=4000")
bench(1000, 4000)
