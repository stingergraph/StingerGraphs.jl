using StingerWrapper
using Base.Test

function generate!(edges, numvertices::Integer, numedges::Integer)
    for i in 1:numedges
        src, dst = rand(0:numvertices-1), rand(0:numvertices-1)
        edges[:,i] = [0, src, dst, 1, 0]
    end
end

function insert!(s::Stinger, edges::AbstractArray)
    numedges = size(edges,2)
    size(edges, 1) == 5 || error("wrong input format")
    for i in 1:numedges
        insert_edge!(s, edges[1,i], edges[2,i], edges[3,i], edges[4,i], edges[5,i])
    end
end

function remove!(s::Stinger, edges, numedges)
    numedges <= size(edges,2) || error("request to delete too many edges")
    size(edges, 1) == 5 || error("wrong input format")
    for i in 1:numedges
        remove_edge!(s, 0, edges[2,i], edges[3,i])
    end
end

function bench(numvertices, numedges)
    info("Allocating a STINGER")
    s = Stinger()
    edges = zeros(Int64, 5, numedges)
    info("Generating the edges")
    @time generate!(edges, numvertices, numedges)
    info("Inserting $(size(edges,2)) edges")
    @time insert!(s, edges)
    @test consistency_check(s, numvertices) == true
    removals = edges[:,randperm(numedges)]
    removals = unique(removals,2)
    @show size(removals)
    info("Removing 1/8 of the edges")
    @time remove!(s, removals, ceil(Int, numedges/8))
    @test consistency_check(s, numvertices) == true
end

info("Setting STINGER Parameters")
ENV["STINGER_MAX_MEMSIZE"] = 10000000
info("small run to precompile")
bench(100, 100)
info("real becnhmark: nv=1000,ne=4000")
bench(1000, 4000)
