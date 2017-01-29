export kcore

"Find the kcore of the graph."
function kcore(s::Stinger, nv::Int64)

    labels = zeros(Int64, nv)
    counts = zeros(Int64, nv)
    kout = Int64(0)
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
        nv,
        kout
    )
    return labels
end
