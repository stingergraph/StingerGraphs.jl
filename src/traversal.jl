export foralledges

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
