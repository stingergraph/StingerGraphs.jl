export bfs, bfsdistances

"""
This version is slower as it makes a call to `stinger_max_active_vertex`,
which is sequential and runs through every vertex in the graph. If you know
the maximum number of active vertices, call `bfs(s, source, nv)` which is faster.
"""
function bfs(s::Stinger, source::Int64)
    bfs(s, source, s[max_nv])
end

function bfs(s::Stinger, source::Int64, nv::Int64)
    nv>source || throw(DimensionMismatch("Attempting to run BFS with source $source in a graph with only $nv vertices."))
    parents = fill(-2, nv) #Initialize parents array with -2's.
    parents[source+1] = -1 #Set source to -1
    next = Vector{Int64}([source])
    sizehint!(next, nv)
    while !isempty(next)
        src = shift!(next) #Get first element
        foralledges(s, src) do edge, src, etype
            direction, neighbor = edgeparse(edge)
            if (direction != 1 && parents[neighbor+1] == -2)
                parents[neighbor+1] = src
                push!(next, neighbor)
            end
        end
    end
    parents
end

"""
This version is slower as it makes a call to `stinger_max_active_vertex`,
which is sequential and runs through every vertex in the graph. If you know
the maximum number of active vertices, call `bfsdistances(s, source, nv)` which is faster.
"""
function bfsdistances(s::Stinger, source::Int64)
    nv = get_nv(s)
    bfsdistances(s, source, nv)
end

"""
Obtain both the `parents` array as well as the `distances` from source.
"""
function bfsdistances(s::Stinger, source::Int64, nv::Int64)
    nv>source || throw(DimensionMismatch("Attempting to run BFS with source $source in a graph with only $nv vertices."))
    parents = fill(-2, nv) #Initialize parents array with -2's.
    distances = fill(-1, nv)
    parents[source+1]=-1 #Set source to -1
    distances[source+1]=0
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
                distances[vertex+1] = distances[src+1] + 1 #Get the distance
            end
        end
    end
    parents, distances
end
