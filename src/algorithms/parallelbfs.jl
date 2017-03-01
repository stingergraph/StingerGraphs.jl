using Base.Threads
using Base.Threads.Atomic
import Base: push!, shift!, isempty, getindex

using UnsafeAtomics

export ThreadQueue, LevelSynchronous, bfs

immutable ThreadQueue{T}
    data::Vector{T}
    head::Atomic{Int}
    tail::Atomic{Int}
end

function ThreadQueue(T::Type, maxlength::Int)
    q = ThreadQueue(Vector{T}(maxlength), Atomic{Int}(1), Atomic{Int}(1))
    return q
end

function push!{T}(q::ThreadQueue{T}, val::T)
    # TODO: check that head > tail
    offset = atomic_add!(q.tail, 1)
    q.data[offset] = val
    return offset
end

function shift!{T}(q::ThreadQueue{T})
    # TODO: check that head < tail
    offset = atomic_add!(q.head, 1)
    return q.data[offset]
end

function isempty(q::ThreadQueue)
    return ( q.head[] == q.tail[] ) && q.head != 1
    # return q.head == length(q.data)
end

function getindex{T}(q::ThreadQueue{T}, iter)
    return q.data[iter]
end

abstract BFSAlgorithm
type LevelSynchronous <: BFSAlgorithm end

function bfskernel(
        alg::LevelSynchronous, s::Stinger, next::ThreadQueue, parents::Array{Int64},
        level::Array{Int64}
    )
    @threads for src in level
        foralledges(s, src) do edge, src, etype
            direction, neighbor = edgeparse(edge)
            if (direction != 1)
                parent = UnsafeAtomics.unsafe_atomic_cas!(parents, neighbor+1, -2, src)
                if parent==-2
                    push!(next, neighbor) #Push onto queue
                end
            end
        end
    end
end

function bfs(alg::LevelSynchronous, s::Stinger, source::Int64, nv::Int64)
    next = ThreadQueue(Int, nv)
    parents = fill(-2, nv)
    bfs(alg, s, next, source, parents)
end

function bfs(
        alg::LevelSynchronous, s::Stinger, next::ThreadQueue, source::Int64,
        parents::Array{Int64}
    )
    parents[source+1]=-1 #Set source to -1
    push!(next, source)
    while !isempty(next)
        level = next[next.head[]:next.tail[]-1]
        next.head[] = next.tail[] #reset the queue
        bfskernel(alg, s, next, parents, level)
    end
    return parents
end
