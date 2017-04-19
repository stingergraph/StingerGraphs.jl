export StingerLGEdge, StingerEdgeIterator

import Base: reverse, ==, convert
import LightGraphs: AbstractEdge, src, dst, reverse

struct StingerLGEdge <: AbstractEdge
    src::Int64
    dst::Int64
    direction::Int64
    weight::Int64
    timefirst::Int64
    timerecent::Int64
end

function src(edge::StingerLGEdge)
    if edge.direction==1
        return edge.dst
    else
        return edge.src
    end
end

function dst(edge::StingerLGEdge)
    if edge.direction==1
        return edge.src
    else
        return edge.dst
    end
end

reverse(edge::StingerLGEdge) = StingerLGEdge(edge.dst, edge.src, edge.direction, edge.weight, edge.timefirst, edge.timerecent)

function ==(e1::StingerLGEdge, e2::StingerLGEdge)
    e1.src == e2.src && e1.dst == e2.dst && e1.direction == e2.direction &&
    e1.weight == e2.weight && e1.timefirst == e2.timefirst && e1.timerecent == e2.timerecent
end

function convert(::Type{Pair}, edge::StingerLGEdge)
    if edge.direction==1
        return Pair(edge.dst, edge.src)
    else
        return Pair(edge.src, edge.dst)
    end
end

function convert(::Type{Tuple}, edge::StingerLGEdge)
    if edge.direction==1
        return (edge.dst, edge.src)
    else
        return (edge.src, edge.dst)
    end
end

StingerLGEdge(t::Tuple) = StingerLGEdge(t[1], t[2], 2, 0, 0, 0)
StingerLGEdge(p::Pair) = StingerLGEdge(p.first, p.second, 2, 0, 0, 0)

function createedge(rawedge::StingerEdge, src::Int64)
    direction, neighbor = edgeparse(rawedge)
    StingerLGEdge(
        src+1, neighbor+1, direction, rawedge.weight, rawedge.timefirst, rawedge.timerecent
    )
end
