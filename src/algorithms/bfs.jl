export bfs

"""
This version is slower as it makes a call to `stinger_max_active_vertex`,
which is sequential and runs through every vertex in the graph. If you know
the maximum number of active vertices, call `bfs(s, source, nv)` which is faster.
"""
function bfs(s::Stinger, source::Int64)
    nv = get_nv(s)
    bfs(s, source, nv)
end

function bfs(s::Stinger, source::Int64, nv::Int64)
    nv>source || throw(DimensionMismatch("Attempting to run BFS with source $source in a graph with only $nv vertices."))
    parents = fill(-2, nv) #Initialize parents array with -2's.
    parents[source+1]=-1 #Set source to -1
    next = Vector{Int64}([source])
    sizehint!(next, nv)
    successors = zeros(Int64, nv)
    while !isempty(next)
        src = shift!(next) #Get first element
        vertexneighbors = getsuccessors!(s, src, successors)
        for i in 1:vertexneighbors
            #If not already set, and is not found in the queue.
            vertex = successors[i]
            if parents[vertex+1]==-2
                push!(next, vertex) #Push onto queue
                parents[vertex+1] = src
            end
        end
    end
    parents
end
