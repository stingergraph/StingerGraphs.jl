import LightGraphs: nv, ne, vertices, edges, neighbors, in_neighbors, out_neighbors,
    has_vertex, has_edge, has_self_loops

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

function has_vertex(g::StingerLG, v::Int64)
    v <= g.nv
end

function has_edge(g::StingerLG, e::StingerLGEdge)
    for edge in StingerVertexEdgeIterator(g.s, e.src-1, e.direction)
        if edge == e
            return true
        end
    end
    return false
end

function has_edge(g::StingerLG, src::Int64, dst::Int64, dir::Int64)
    has_edge(g, StingerLGEdge(src, dst, dir, 0, 0, 0))
end

has_self_loops(g::StingerLG) = false
