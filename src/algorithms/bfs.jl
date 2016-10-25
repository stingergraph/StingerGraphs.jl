export bfs

function bfs(s::Stinger, source::Int)
    nv = s[max_nv]
    visited = falses(nv) #Initialize with false
    parents = fill(-1, nv) #Initialize parents array with -1's.
    next = Vector{Int64}([source])
    sizehint!(next, nv)
    while !isempty(next)
        src = shift!(next) #Get first element
        vertexneighbors = getsuccessors(s, src)
        for vertex in vertexneighbors
            #If not already set, and is not found in the queue.
            if !visited[vertex+1]
                push!(next, vertex+1) #Push onto queue
                visited[vertex+1] = true #Mark that it is has been visited.
                parents[vertex+1] = src
            end
        end
    end
    parents
end
