using StingerWrapper
using BenchmarkTools
using JLD

function setupgraph(
    scale::Int64,
    edgefactor::Int64;
    a::Float64=0.57,
    b::Float64=0.19,
    c::Float64 = 0.19
    )
    graph = kronecker(scale, edgefactor, a=a, b=b, c=c)
    s = Stinger()
    for i in 1:size(graph, 2)
        insert_edge!(s, 0, graph[1, i], graph[2, i], 1, 1)
    end
    return s
end

function bfsbenchutil(s::Stinger, nv::Int64)
    for i in 0:1000
        bfs(s, i, nv)
    end
end

function bench(
    scale::Int64,
    edgefactor::Int64;
    a::Float64=0.57,
    b::Float64=0.19,
    c::Float64 = 0.19,
    filename::String="bfs_bench.jld"
    )
    nv = 2^scale
    bfs_bench = @benchmarkable bfsbenchutil(s, $nv) seconds=10 setup=(s=setupgraph($scale, $edgefactor))
    info("Running BFS benchmark")
    bfs_trial = run(bfs_bench)
    jldopen(filename, "w") do f
        write(f, "bfs_trial_$(scale)_$(edgefactor)", bfs_trial)
    end
    bfs_trial
end

function benchgroup(
        scales::Range{Int64},
        edgefactor::Int64;
        a::Float64=0.57,
        b::Float64=0.19,
        c::Float64 = 0.19,
        filename::String="bfs_bench_group.jld"
    )
    jldopen(filename, "w") do f
        for scale in scales
            bfs_trial = bench(scale, edgefactor, a=a, b=b, c=c)
            write(f, "bfs_trial_$(scale)_$(edgefactor)", bfs_trial)
        end
    end
    filename
end
