export StingerLGEdge, StingerEdgeIterator

import Base: start, done, next, reverse, ==, convert

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

struct StingerEdgeIterator
    s::Stinger
end

mutable struct StingerEdgeIteratorState
    ebpool_priv_ptr::Ptr{Void}
    current_eb_ptr::Ptr{Void}
    current_eb::StingerEdgeBlock
    current_eb_edge_idx::Int64
    ETA_ptr::Ptr{Void}
    current_ETA::StingerEdgeArray
    current_ETA_index::Int64
    etype::Int64
    netypes::Int64
end

function edges(g::StingerLG)
    StingerEdgeIterator(g.s)
end

function start(iterator::StingerEdgeIterator)
    ebpool_priv_ptr = storageptr(iterator.s) + iterator.s[ebpool_start] * (sizeof(UInt8)) + sizeof(UInt64) * 2
    ETA_ptr = ETAptr(iterator.s, 0)
    current_ETA = unsafe_load(convert(Ptr{StingerEdgeArray}, ETA_ptr))
    current_eb_ptr = ebpool_priv_ptr + unsafe_load(convert(Ptr{UInt64}, ETA_ptr+sizeof(StingerEdgeArray))) * (sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS)
    current_eb = unsafe_load(convert(Ptr{StingerEdgeBlock}, current_eb_ptr))
    StingerEdgeIteratorState(
        ebpool_priv_ptr,
        current_eb_ptr,
        current_eb,
        1,
        ETA_ptr,
        current_ETA,
        1,
        0,
        iterator.s[max_netypes]
    )
end

function done(iterator::StingerEdgeIterator, state::StingerEdgeIteratorState)
    state.etype == state.netypes
end

function next(iterator::StingerEdgeIterator, state::StingerEdgeIteratorState)
    #Load the current edge
    rawedge = unsafe_load(
        convert(Ptr{StingerEdge}, state.current_eb_ptr+sizeof(StingerEdgeBlock)),
        state.current_eb_edge_idx
    )
    parsededge = createedge(rawedge, state.current_eb.vertexid)
    #Now set the state to the next edge
    state.current_eb_edge_idx+=1
    #Check if edgeblock completed
    if (state.current_eb_edge_idx > state.current_eb.high)
        state.current_ETA_index+=1
        #Check if all edgeblocks in the ETA are done
        if (state.current_ETA_index > state.current_ETA.high)
            state.etype+=1
            if (state.etype == state.netypes)
                #Termination condition
                return (parsededge, state)
            end
            #Update ETA state
            state.current_ETA_index=1
            state.ETA_ptr = ETAptr(iterator.s, state.etype)
            state.current_ETA = unsafe_load(convert(Ptr{StingerEdgeArray}, ETA_ptr))
        end
        #Update edgeblock state
        state.current_eb_edge_idx = 1
        state.current_eb_ptr = state.ebpool_priv_ptr +
            unsafe_load(
                convert(Ptr{UInt64}, state.ETA_ptr+sizeof(StingerEdgeArray)),
                state.current_ETA_index
            ) * (sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS)
        state.current_eb = unsafe_load(convert(Ptr{StingerEdgeBlock}, state.current_eb_ptr))
    end
    return (parsededge, state)
end

function createedge(rawedge::StingerEdge, src::Int64)
    direction, neighbor = edgeparse(rawedge)
    StingerLGEdge(
        src+1, neighbor+1, direction, rawedge.weight, rawedge.timefirst, rawedge.timerecent
    )
end
