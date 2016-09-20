using StingerWrapper
using BenchmarkTools
using JLD
using Base.Test

const seed = 1

function generate!(edges, numvertices::Integer, numedges::Integer, rng=srand(seed))
    for i in 1:numedges
        src, dst = rand(rng, 0:numvertices-1), rand(rng, 0:numvertices-1)
        edges[:,i] = [src, dst]
    end
end

function bench(numvertices=10000, numedges=100000, filename="insertremovetrails.jld")
    s = Stinger()
    edges = zeros(Int64, 2, numedges)
    generate!(edges, numvertices, numedges)
    info("Benchmarking inserts")
    idx = 1
    inserttrial = @benchmark insert_edge!($s, 0, src, dst, 1, 0) seconds=10 samples=numedges setup=src,dst=$(edges)[:, $idx];idx+=1
    idx = 1
    info("Benchmarking removals")
    removetrial = @benchmark insert_edge!($s, 0, src, dst, 1, 0) seconds=10 samples=ceil(Int, numedges/4) setup=src,dst=edges[:, $idx];idx+=1

    jldopen(filename, "w") do f
        write(f, "inserttrial", inserttrial)
        write(f, "removetrial", removetrial)
    end

    return s, inserttrial, removetrial
end
