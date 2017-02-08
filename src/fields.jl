import Base: getindex, setindex!
export get_nv, storageptr

function getindex(x::Stinger, field::StingerFields)
    idx = Int(field)
    if field == batch_time || field == update_time
        error("For $field use get_$field()")
    end
    basepointer = convert(Ptr{Int64}, x.handle)
    unsafe_load(basepointer, idx)
end

function get_batchtime(x::Stinger)
    basepointer = convert(Ptr{Float64}, x.handle)
    unsafe_load(basepointer, Int(batch_time))
end

function get_updatetime(x::Stinger)
    basepointer = convert(Ptr{Float64}, x.handle)
    unsafe_load(basepointer, Int(update_time))
end

function setindex!(x::Stinger, val, field::StingerFields)
    idx = Int(field)
    ftype = fieldtype(StingerGraph, idx)
    @assert isa(val, ftype)
    basepointer = convert(Ptr{ftype}, x.handle)
    unsafe_store!(basepointer,val,idx)
end

"""Returns number of active vertices in the graph. This is based on the largest
vertex ID which has a non-zero indegree or outdegree."""
function get_nv(x::Stinger)
    nv = ccall(
        dlsym(stinger_core_lib, "stinger_max_active_vertex"),
        Int64,
        (Ptr{Void},),
        x
    )
    nv==0 && return nv
    nv+1
end

"""Get a pointer to the storage array of Stinger"""
storageptr(s::Stinger) = s.handle + sizeof(StingerGraph) + 5*sizeof(UInt64)
