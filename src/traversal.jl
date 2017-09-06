export foralledges

"""
    foralledges(f::Function, s::Stinger, v::Int64)

Iterates over all the edges edges of a vertex and applies a function to each
edge. The function should take 3 arguments.
`f(current_edge::StingerEdge, vertexid::Int64, etype::Int64)`
"""
function foralledges(f::Function, s::Stinger, v::Int64)
    ebpool_priv_ptr = storageptr(s) + s[ebpool_start] * (sizeof(UInt8)) + sizeof(UInt64) * 2
    current_eb_ptr = ebpool_priv_ptr + getvertex(s, v).edges * (sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS)
    while current_eb_ptr != ebpool_priv_ptr
        current_eb = unsafe_load(convert(Ptr{StingerEdgeBlock}, current_eb_ptr))
        for i=1:current_eb.high
            current_edge = unsafe_load(convert(Ptr{StingerEdge}, current_eb_ptr+sizeof(StingerEdgeBlock)), i)
            f(current_edge, current_eb.vertexid, current_eb.etype)
        end
        current_eb_ptr = ebpool_priv_ptr + current_eb.next * (sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS);
    end
end
