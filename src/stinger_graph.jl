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
end

export max_nv, max_neblock, max_netypes, max_nvtypes, num_insertions, num_deletions,
num_insertions_last_batch, num_deletions_last_batch, batch_time, update_time, queue_size,
dropped_batches, vertices_start, physmap_start, etype_names_start, vtype_names_start,
ETA_start, ebpool_start, size_t

const stingergraphfields = fieldnames(StingerGraph)

"""
Generates an Enumeration of all fields in `StingerGraph`.
The generated fields are of type `StingerFields`.
"""
macro createfieldenums()
    enumexp = :(@enum StingerFields)
    for (idx, field) in enumerate(fieldnames(StingerWrapper.StingerGraph))
        push!(enumexp.args, :($(esc(field))=$(esc(idx))))
    end
    enumexp
end

@createfieldenums()
