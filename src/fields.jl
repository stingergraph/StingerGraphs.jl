import Base: getindex, setindex!

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
