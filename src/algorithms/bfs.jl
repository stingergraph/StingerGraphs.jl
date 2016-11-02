export bfs

function bfs(s::Stinger, source::Int)
    nv = get_nv(s)
    nv>source || throw(DimensionMismatch("Attempting to run BFS with source $source in a graph with only $nv vertices."))
    parents = fill(-2, nv) #Initialize parents array with -2's.
    parents[source+1]=-1 #Set source to -1
    next = Vector{Int64}([source])
    sizehint!(next, nv)
    while !isempty(next)
        src = shift!(next) #Get first element
        vertexneighbors = getsuccessors(s, src)
        for vertex in vertexneighbors
            #If not already set, and is not found in the queue.
            if parents[vertex+1]==-2
                push!(next, vertex) #Push onto queue
                parents[vertex+1] = src
            end
        end
    end
    parents
end
