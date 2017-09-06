using StingerGraphs
using BenchmarkTools
using JLD

const seed = 10^4

function generate!(edges, numvertices::Integer, numedges::Integer, rng=srand(seed))
    for i in 1:numedges
        src, dst = rand(rng, 0:numvertices-1), rand(rng, 0:numvertices-1)
        while src==dst
            dst = rand(rng, 0:numvertices-1)
        end
        edges[:,i] = [0, src, dst, 0, 0]
    end
end

function setup_stinger(edges, numedges)
    s = Stinger()
    insert_edges!(s, edges, numedges)
    return s
end

function insert_remove(s, edges, numedges)
    insert_edges!(s, edges, numedges)
    remove_edges!(s, edges, numedges)
end

function bench(numvertices=10000, numedges=1000000, filename="add_remove_bench.jld")

    edges = zeros(Int64, 5, numedges)
    generate!(edges, numvertices, numedges)
    removals = unique(edges, 2)
    numremovals = size(removals, 2)
    info("$(size(removals,2)) unique edges being inserted and removed")

    insert_bench = @benchmarkable insert_edges!(s, $edges, $numedges) seconds=10 setup=(s=Stinger())
    remove_bench = @benchmarkable remove_edges!(s, $removals, $numremovals) seconds=10 setup=(s=setup_stinger($edges, $numedges))
    insert_remove_bench = @benchmarkable insert_remove(s, $removals, $numremovals) seconds=10 setup=(s=Stinger())

    info("Running insert benchmark")
    insert_trial = run(insert_bench)
    info("Running removals benchmark")
    remove_trial = run(remove_bench)
    info("Running insert and remove benchmark")
    insert_remove_trial = run(insert_remove_bench)


    jldopen(filename, "w") do f
        write(f, "insert_trial", insert_trial)
        write(f, "remove_trial", remove_trial)
        write(f, "insert_remove_trial", insert_remove_trial)
    end

    return insert_trial, remove_trial, insert_remove_trial
end
