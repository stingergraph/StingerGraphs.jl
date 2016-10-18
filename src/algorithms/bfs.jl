export bfs

function bfs(s::Stinger, source::Int)
    nv = s[max_nv]
    visited = falses(nv) #Initialize with false
    next = Vector{Int64}([source])
    sizehint!(next, s[max_nv])
    while !isempty(next)
        src = shift!(next) #Get first element
        vertexneighbors = getsuccessors(s, src)
        for vertex in vertexneighbors
            #If not already set, and is not found in the queue.
            if !visited[vertex]
                push!(next, vertex) #Push onto queue
                visited[vertex] = true #Mark that it is has been visited.
            end
        end
    end
    findin(visited, true) #Return all vertices that are set to true
end
