using LightGraphs
import LightGraphs: AbstractGraph

type StingerLG{T} <: AbstractGraph
    s::Stinger
    nv::T
end

StingerLG() = StingerLG(Stinger(), 0)

function add_edge!(s::StingerLG, e::LightGraphs.SimpleGraphs.SimpleEdge)
    insert_edge!(s.s, 0, e.src, e.dst, 0, 0)
end

function rem_edge!(s::StingerLG, e::LightGraphs.SimpleGraphs.SimpleEdge)
    remove_edge!(s.s, 0, e.src, e.dst)
end

#QUESTION: Should I look at changing the stinger config for these?

function add_vertex!(s::StingerLG)
    if (s.nv + 1 < s.s[max_nv])
        s.nv+=1
        return true
    else
        return false
    end
end

function add_vertices!(s::StingerLG, n::Integer)
    if (s.nv + n < s.s[max_nv])
        s.nv+=n
        return true
    else
        return false
    end
end

function rem_vertex!(s::StingerLG)
    if s.nv > 0
        s.nv -= 1
        return true
    else
        return false
    end
end

function zero(s::StingerLG)
    StingerLG(Stinger(), 0)
end
