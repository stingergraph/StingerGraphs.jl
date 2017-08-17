immutable StingerGraph
    max_nv::Int64
    max_neblock::Int64
    max_netypes::Int64
    max_nvtypes::Int64
    num_insertions::Int64
    num_deletions::Int64
    num_insertions_last_batch::Int64
    num_deletions_last_batch::Int64

    batch_time::Float64
    update_time::Float64

    queue_size::Int64
    dropped_batches::Int64
    vertices_start::Int64
    physmap_start::Int64
    etype_names_start::Int64
    vtype_names_start::Int64

    ETA_start::Int64
    ebpool_start::Int64
    size_t::UInt

    #cache_pad::Array{Int64}(5)
    #storage - Zero sized array (use `storageptr` to get a pointer to this)
end

export max_nv, max_neblock, max_netypes, max_nvtypes, num_insertions, num_deletions,
num_insertions_last_batch, num_deletions_last_batch, batch_time, update_time, queue_size,
dropped_batches, vertices_start, physmap_start, etype_names_start, vtype_names_start,
ETA_start, ebpool_start, size_t

const stingergraphfields = fieldnames(StingerGraph)

@enum StingerFields max_nv=1 max_neblock=2 max_netypes=3 max_nvtypes=4 num_insertions=5 num_deletions=6 num_insertions_last_batch=7 num_deletions_last_batch=8 batch_time=9 update_time=10 queue_size=11 dropped_batches=12 vertices_start=13 physmap_start=14 etype_names_start=15 vtype_names_start=16 ETA_start=17 ebpool_start=18 size_t=19
