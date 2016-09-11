import Base: getindex, setindex!

for field in fieldnames(StingerGraph)
    datatype = fieldtype(StingerGraph, field)
    idx = findfirst(stingergraphfields, field)
    getfname = Symbol("get_$field")
    setfname = Symbol("set_$field")
    eval(
        quote
            export $getfname, $setfname
            $(getfname)(x::Stinger) = unsafe_load(convert(Ptr{$datatype}, x.handle), $idx)
            $(setfname)(x::Stinger, val::$datatype) = begin
                unsafe_store!(convert(Ptr{$datatype}, x.handle), val, $idx)
            end
        end
    )
end

function getindex(x::Stinger, field::Symbol)
    @assert field in stingergraphfields "Field does not exist in StingerGraph"
    fname = Symbol("get_$field")
    tempf = x -> eval(:($fname($x)))
    tempf(x)
end

function setindex!(x::Stinger, val, field::Symbol)
    fname = Symbol("set_$field")
    tempf = (x, val, fname) -> eval(:($fname($x, $val)))
    tempf(x, val, fname)
end
