function nv(g::StingerLG)
    g.nv
end

function ne(g::StingerLG)
    ne = 0
    for edge in edges(g, 2)
        ne+=1
    end
    ne
end

function vertices(g::StingerLG)
    #Convert to 0 based on all the interface functions.
    1:g.nv
end

function edges(g::StingerLG, dir::Int64=2)
    StingerEdgeIterator(g.s, dir)
end

function neighbors(g::StingerLG, src::Int64, dir::Int64=2)
    neighbors = Vector{Int64}()
    for edge in StingerVertexEdgeIterator(g.s, src-1, dir)
        push!(neighbors, edge.dst)
    end
    neighbors
end

function in_neighbors(g::StingerLG, src::Int64)
    neighbors(g, src, 1)
end

function out_neighbors(g::StingerLG, src::Int64)
    neighbors(g, src, 2)
end
