import Base: start, done, next

abstract type AbstractStingerEdgeIterator end

eltype(::Type{AbstractStingerEdgeIterator}) = StingerLGEdge
iteratorsize(::Type{AbstractStingerEdgeIterator}) = Base.SizeUnknown()

"""To  iterator over an EdgeBlock"""
struct EdgeBlockIterator <: AbstractStingerEdgeIterator
    current_eb_ptr::Ptr{Void}
    current_eb::StingerEdgeBlock
end

struct EdgeBlockIteratorState
    current_eb_edge_idx::Int64
    current_edge::StingerLGEdge
end

"""Iterate till the first non blank edge or until done condition"""
function start(iter::EdgeBlockIterator)
    for init_eb_edge_idx=1:iter.current_eb.high
        rawedge = unsafe_load(
            convert(Ptr{StingerEdge}, iter.current_eb_ptr+sizeof(StingerEdgeBlock)),
            init_eb_edge_idx
        )
        if rawedge.neighbor >= 0
            #Set state on finding a valid edge
            return EdgeBlockIteratorState(
                init_eb_edge_idx,
                createedge(rawedge, iter.current_eb.vertexid)
            )
        end
    end
    #Return done state if no valid edge found
    EdgeBlockIteratorState(iter.current_eb.high+1, StingerLGEdge(0, 0, 0, 0, 0, 0))
end

function done(iter::EdgeBlockIterator, state::EdgeBlockIteratorState)
    state.current_eb_edge_idx > iter.current_eb.high
end

"""Loads the edge pointed to by state, updates state when next non-blank edge is found or termination condition is satisfied"""
function next(iter::EdgeBlockIterator, state::EdgeBlockIteratorState)
    current_edge = state.current_edge
    for edge_idx=state.current_eb_edge_idx+1:iter.current_eb.high
        rawedge = unsafe_load(
            convert(Ptr{StingerEdge}, iter.current_eb_ptr+sizeof(StingerEdgeBlock)),
            edge_idx
        )
        if rawedge.neighbor >= 0
            #Set state on finding a valid edge
            return (
                current_edge,
                EdgeBlockIteratorState(
                    edge_idx,
                    createedge(rawedge, iter.current_eb.vertexid)
                )
            )
            break
        end
    end
    return (
        current_edge,
        EdgeBlockIteratorState(iter.current_eb.high+1, current_edge)
    )
end

struct StingerEdgeIterator <: AbstractStingerEdgeIterator
    s::Stinger
    ebpool_priv_ptr::Ptr{Void}
    netypes::Int64
end

function StingerEdgeIterator(s::Stinger)
    ebpool_priv_ptr = storageptr(s) + s[ebpool_start] * (sizeof(UInt8)) + sizeof(UInt64) * 2
    netypes = s[max_netypes]
    StingerEdgeIterator(s, ebpool_priv_ptr, netypes)
end

struct StingerEdgeIteratorState
    ETA_ptr::Ptr{Void}
    current_ETA::StingerEdgeArray
    current_ETA_index::Int64
    etype::Int64
    eb_iterator::EdgeBlockIterator
    eb_iterator_state::EdgeBlockIteratorState
end

function start(iter::StingerEdgeIterator)
    for etype=0:iter.netypes-1
        ETA_ptr = ETAptr(iter.s, etype)
        current_ETA = unsafe_load(convert(Ptr{StingerEdgeArray}, ETA_ptr))
        for current_ETA_index=1:current_ETA.high
            current_eb_ptr = iter.ebpool_priv_ptr +
                unsafe_load(
                    convert(Ptr{UInt64}, ETA_ptr+sizeof(StingerEdgeArray))
                    ) *
                    (sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS)
            current_eb = unsafe_load(convert(Ptr{StingerEdgeBlock}, current_eb_ptr))

            eb_iterator = EdgeBlockIterator(current_eb_ptr, current_eb)
            eb_iterator_state = start(eb_iterator)
            if(!(done(eb_iterator, eb_iterator_state)))
                return StingerEdgeIteratorState(
                    ETA_ptr,
                    current_ETA,
                    current_ETA_index,
                    etype,
                    eb_iterator,
                    eb_iterator_state
                )
            end
        end
    end
    StingerEdgeIteratorState(
        Ptr{Void}(0),
        StingerEdgeArray(0, 0),
        0,
        iter.netypes,
        EdgeBlockIterator(Ptr{Void}(0), StingerEdgeBlock(0, 0, 0, 0, 0, 0, 0, 0)),
        EdgeBlockIteratorState(0, StingerLGEdge(0, 0, 0, 0, 0, 0))
    )
end

function done(iter::StingerEdgeIterator, state::StingerEdgeIteratorState)
    state.etype == iter.netypes
end

function next(iter::StingerEdgeIterator, state::StingerEdgeIteratorState)
    #Load the current edge
    (current_edge, eb_iterator_state) = next(state.eb_iterator, state.eb_iterator_state)
    ETA_ptr = state.ETA_ptr
    current_ETA = state.current_ETA
    current_ETA_index = state.current_ETA_index
    etype = state.etype
    eb_iterator = state.eb_iterator
    #If edgeblock completed
    while done(eb_iterator, eb_iterator_state)
        current_ETA_index+=1
        if (current_ETA_index > current_ETA.high)
            #ETA done, move on to next etype
            etype+=1
            if (etype == iter.netypes)
                #DONE condition
                return (
                    current_edge,
                    StingerEdgeIteratorState(
                        Ptr{Void}(0),
                        StingerEdgeArray(0, 0),
                        0,
                        iter.netypes,
                        EdgeBlockIterator(Ptr{Void}(0), StingerEdgeBlock(0, 0, 0, 0, 0, 0, 0, 0)),
                        EdgeBlockIteratorState(0, StingerLGEdge(0, 0, 0, 0, 0, 0))
                    )
                )
            end
            current_ETA_index=1
            ETA_ptr = ETAptr(iter.s, etype)
            current_ETA = unsafe_load(convert(Ptr{StingerEdgeArray}, ETA_ptr))
        end
        current_eb_ptr = iter.ebpool_priv_ptr +
            unsafe_load(
                convert(Ptr{UInt64}, ETA_ptr+sizeof(StingerEdgeArray)),
                current_ETA_index
            ) *
            (sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS)
        current_eb = unsafe_load(convert(Ptr{StingerEdgeBlock}, current_eb_ptr))
        eb_iterator = EdgeBlockIterator(current_eb_ptr, current_eb)
        eb_iterator_state = start(eb_iterator)
    end

    return (
        current_edge,
        StingerEdgeIteratorState(
            ETA_ptr,
            current_ETA,
            current_ETA_index,
            etype,
            eb_iterator,
            eb_iterator_state
        )
    )
end

struct StingerDirectedEdgesIterator <: AbstractStingerEdgeIterator
    edgeiter::StingerEdgeIterator
    direction::Int64
end

function start(iter::StingerDirectedEdgesIterator)
    state = start(iter.edgeiter)
    while(!done(iter.edgeiter, state) && xor(state.eb_iterator_state.current_edge.direction,iter.direction)==3)
        (_, state) = next(iter.edgeiter, state)
    end
    state
end

function next(iter::StingerDirectedEdgesIterator, state::StingerEdgeIteratorState)
    current_edge, state = next(iter.edgeiter, state)
    while(!done(iter.edgeiter, state) && xor(state.eb_iterator_state.current_edge.direction,iter.direction)==3)
        edge, state = next(iter.edgeiter, state)
    end
    (current_edge, state)
end

function done(iter::StingerDirectedEdgesIterator, state::StingerEdgeIteratorState)
    done(iter.edgeiter, state)
end

struct StingerVertexEdgeIterator <: AbstractStingerEdgeIterator
    ebpool_priv_ptr::Ptr{Void}
    vertex::StingerVertex
end

function StingerVertexEdgeIterator(s::Stinger, src::Int64)
    ebpool_priv_ptr = storageptr(s) + s[ebpool_start] * (sizeof(UInt8)) + sizeof(UInt64) * 2
    vertex = getvertex(s, src)
    StingerVertexEdgeIterator(
        ebpool_priv_ptr,
        vertex
    )
end

struct StingerVertexEdgeIteratorState
    eb_iter::EdgeBlockIterator
    eb_state::EdgeBlockIteratorState
end

function start(iter::StingerVertexEdgeIterator)
    current_eb_ptr = iter.ebpool_priv_ptr + iter.vertex.edges * (sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS)
    current_eb = unsafe_load(convert(Ptr{StingerEdgeBlock}, current_eb_ptr))
    eb_iter = EdgeBlockIterator(current_eb_ptr, current_eb)
    eb_state = start(eb_iter)
    while (iter.ebpool_priv_ptr != eb_iter.current_eb_ptr && done(eb_iter, eb_state))
        current_eb_ptr = iter.ebpool_priv_ptr + eb_iter.current_eb.next * (sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS)
        current_eb = unsafe_load(convert(Ptr{StingerEdgeBlock}, current_eb_ptr))
        eb_iter = EdgeBlockIterator(current_eb_ptr, current_eb)
        eb_state = start(eb_iter)
    end
    StingerVertexEdgeIteratorState(eb_iter, eb_state)
end

function done(iter::StingerVertexEdgeIterator, state::StingerVertexEdgeIteratorState)
    iter.ebpool_priv_ptr == state.eb_iter.current_eb_ptr
end

function next(iter::StingerVertexEdgeIterator, state::StingerVertexEdgeIteratorState)
    current_edge, eb_state = next(state.eb_iter, state.eb_state)
    eb_iter = state.eb_iter
    while (iter.ebpool_priv_ptr != eb_iter.current_eb_ptr && done(eb_iter, eb_state))
        current_eb_ptr = iter.ebpool_priv_ptr + eb_iter.current_eb.next * (sizeof(StingerEdgeBlock) + sizeof(StingerEdge)*NUMEDGEBLOCKS)
        current_eb = unsafe_load(convert(Ptr{StingerEdgeBlock}, current_eb_ptr))
        eb_iter = EdgeBlockIterator(current_eb_ptr, current_eb)
        eb_state = start(eb_iter)
    end
    (current_edge, StingerVertexEdgeIteratorState(eb_iter, eb_state))
end
