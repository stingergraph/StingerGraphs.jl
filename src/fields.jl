import Base: getindex

for field in fieldnames(StingerGraph)
    datatype = fieldtype(StingerGraph, field)
    idx = findfirst(stingergraphfields, field)
    fname = Symbol("get_$field")
    eval(
        quote
            export $fname
            $(fname)(x::Stinger) = unsafe_load(convert(Ptr{$datatype}, x.handle), $idx)
        end
    )
end

function getindex(x::Stinger, field::Symbol)
    @assert field in stingergraphfields "Field does not exist in StingerGraph"
    fname = Symbol("get_$field")
    eval(
        :($fname($x))
    )
end
