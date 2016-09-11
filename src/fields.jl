import Base: getindex, setindex!

function getindex(x::Stinger, field::StingerFields)
    idx = Int(field)
    basepointer = convert(Ptr{fieldtype(StingerGraph, idx)}, x.handle)
    unsafe_load(basepointer, idx)
end

function setindex!(x::Stinger, val, field::StingerFields)
    idx = Int(field)
    ftype = fieldtype(StingerGraph, idx)
    @assert isa(val, ftype)
    basepointer = convert(Ptr{ftype}, x.handle)
    unsafe_store!(basepointer,val,idx)
end
