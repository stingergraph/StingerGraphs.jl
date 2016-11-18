using StingerWrapper
using Base.Test

function bfsutil(scale::Int64, edgefactor::Int64)
    graph = kronecker(scale, edgefactor)
    s = Stinger()
    for i in 1:size(graph, 2)
        insert_edge!(s, 0, graph[1, i], graph[2, i], 1, 1)
    end
    nv = get_nv(s)
    for src in 0:nv-1
        parents = bfs(s, src)
        bfstest(s, parents)
    end
    return s
end

function bfstest(s::Stinger, parents::Array{Int64, 1}; weight::Int64=1, etype::Int64=0)
    for i in 1:size(parents, 1)
        #Check if edge exists
        if parents[i]>-1
            @test edgeweight(s, parents[i], i-1, etype) != 0
        end
    end
end
