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

const stingergraphfields = fieldnames(StingerGraph)

function createfieldenums()
    enumexp = :(@enum StingerFields)
    for (idx, field) in enumerate(stingergraphfields)
        eval(:(export $field))
        push!(enumexp.args, :($field=$idx))
    end
    eval(enumexp)
end

createfieldenums()
