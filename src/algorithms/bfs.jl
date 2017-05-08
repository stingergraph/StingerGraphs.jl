export bfs, bfsdistances, getsuccessorsbfs

"""
This version is slower as it allocates the maximum possible vertices in the Stinger
graph. If you know the maximum number of active vertices, call `bfs(s, source, nv)`
which is faster.
"""
function bfs(s::Stinger, source::Int64)
    bfs(s, source, s[max_nv])
end

"""
`bfs` returns a parents array of length `nv`. An empty array is returned on
failure.
"""
function bfs(s::Stinger, source::Int64, nv::Int64)
    if source>=nv
        return zeros(Int64, 0)
    end
    bfskernel(s, source, nv)
end

function getsuccessorsbfs(s::Stinger, source::Int64, nv::Int64)
    if source>=nv
        return zeros(Int64, 0)
    end
    getsuccessorsbfskernel(s, source, nv)
end

function bfskernel(s::Stinger, source::Int64, nv::Int64)
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

function getsuccessorsbfskernel(s::Stinger, source::Int64, nv::Int64)
    parents = fill(-2, nv) #Initialize parents array with -2's.
    parents[source+1] = -1 #Set source to -1
    next = Vector{Int64}([source])
    sizehint!(next, nv)
    while !isempty(next)
        src = shift!(next) #Get first element
        neighbors = getsuccessors(s, src)
        for neighbor in neighbors
            if (parents[neighbor+1] == -2)
                parents[neighbor+1] = src
                push!(next, neighbor)
            end
        end
    end
    parents
end
"""
This version is slower as it allocates the maximum possible vertices in the Stinger
graph. If you know the maximum number of active vertices, call `bfsdistances(s, source, nv)`
which is faster.
"""
function bfsdistances(s::Stinger, source::Int64)
    bfsdistances(s, source, s[max_nv])
end

"""
Obtain both the `parents` array as well as the `distances` from source.
Empty arrays are returned on failure.
"""
function bfsdistances(s::Stinger, source::Int64, nv::Int64)
    if source>=nv
        return zeros(Int64, 0), zeros(Int64, 0)
    end
    bfsdistanceskernel(s, source, nv)
end

function bfsdistanceskernel(s::Stinger, source::Int64, nv::Int64)
    parents = fill(-2, nv) #Initialize parents array with -2's.
    distances = fill(-1, nv)
    parents[source+1]=-1 #Set source to -1
    distances[source+1]=0
    next = Vector{Int64}([source])
    sizehint!(next, nv)
    while !isempty(next)
        src = shift!(next) #Get first element
        foralledges(s, src) do edge, src, etype
            direction, neighbor = edgeparse(edge)
            #If edge direction is out and the parent is not set yet.
            if (direction != 1 && parents[neighbor+1] == -2)
                parents[neighbor+1] = src
                distances[neighbor+1] = distances[src+1] + 1
                push!(next, neighbor)
            end
        end
    end
    parents, distances
end
