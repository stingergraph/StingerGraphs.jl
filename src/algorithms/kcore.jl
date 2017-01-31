export kcore

function kcore!(s::Stinger, labels::Array{Int64}, counts::Array{Int64})
    kout = Int64(0)
    assert(length(labels)==length(counts))
    ccall(
        dlsym(stinger_alg_lib, "kcore_find"),
        Void,
        (
            Ptr{Void},
            Ref{Int64},
            Ref{Int64},
            Int64,
            Ref{Int64}
        ),
        s,
        labels,
        counts,
        length(counts),
        kout
    )
end


"Find the kcore of the graph."
function kcore(s::Stinger, nv::Int64)
    labels = zeros(Int64, nv)
    counts = zeros(Int64, nv)
    kcore!(s, labels, counts)
    return labels, counts
end

"""
This version is slower as it makes a call to `stinger_max_active_vertex`,
which is sequential and runs through every vertex in the graph. If you know
the maximum number of active vertices, call `kcore(s, nv)` which is faster.
"""
function kcore(s::Stinger)
    nv = get_nv(s)
    kcore(s, nv)
end
