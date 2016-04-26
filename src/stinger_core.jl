import Base.Libdl: dlopen, dlsym
import Base: unsafe_convert

export Stinger, remove_edge!, insert_edge!, consistency_check

if "STINGER_LIB_PATH" in keys(ENV)
    stinger_core_lib = dlopen(joinpath(ENV["STINGER_LIB_PATH"],"libstinger_core"))
else
    stinger_core_lib = dlopen("libstinger_core")
end


type Stinger
    handle::Ptr{Void}

    #Default constructor to create a Stinger data structure
    function Stinger()
        s = new(ccall(dlsym(stinger_core_lib, "stinger_new"), Ptr{Void}, ()))
        finalizer(s, stinger_free)
        s
    end
end

unsafe_convert{T}(::Type{Ptr{T}}, s::Stinger) = s.handle

function stinger_free(x::Stinger)
    # To prevent segfaults
    if x.handle != C_NULL
        x.handle = ccall(dlsym(stinger_core_lib, "stinger_free"), Ptr{Void}, (Ptr{Void},), x)
    end
end

#Equivalent of stinger_set_initial_edges
function Stinger(
    nv::UInt,
    etype::Int64,
    offsets::Vector{Int64},
    adj::Vector{Int64},
    weights::Vector{Int64},
    timestamps::Vector{Int64},
    firsttimestamps::Vector{Int64},
    singletimestamp::Int64
    )
    s = Stinger()
    if isempty(timestamps)
        timestamps = C_NULL
    end
    if isempty(firsttimestamps)
        firsttimestamps = C_NULL
    end
    ccall(
        dlsym(stinger_core_lib, "stinger_set_initial_edges"),
        Void,
        (Ptr{Void}, UInt, Int64, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Int64),
        s, nv, etype, offsets, adj, weights, timestamps, firsttimestamps, singletimestamp
    )
    s
end

#Convenience function to not have to specify UInt for nv
function Stinger(
    nv::Int64,
    etype::Int64,
    offsets::Vector{Int64},
    adj::Vector{Int64},
    weights::Vector{Int64},
    timestamps::Vector{Int64},
    firsttimestamps::Vector{Int64},
    singletimestamp::Int64
    )
    if nv<=0
        error("No of vertices must be a positive integer")
    end
    Stinger(UInt(nv), etype, offsets, adj, weights, timestamps, firsttimestamps, singletimestamp)
end

function remove_edge!(s::Stinger, etype::Int64, from::Int64, to::Int64)
    status = ccall(
        dlsym(stinger_core_lib, "stinger_remove_edge"),
        Int32,
        (Ptr{Void}, Int64, Int64, Int64),
        s, etype, from, to
    )
    if status == 0
        error("Edge not found")
    end
    if status == -1
        error("Error while removing the edge")
    end
    status
end

function insert_edge!(
    s::Stinger, etype::Int64, from::Int64, to::Int64, weight::Int64, timestamp::Int64
    )
    status = ccall(
        dlsym(stinger_core_lib, "stinger_insert_edge"),
        Int32,
        (Ptr{Void}, Int64, Int64, Int64, Int64, Int64),
        s, etype, from, to, weight, timestamp
    )
    if status == -1
        error("Error while adding edge")
    end
    status
end

function consistency_check(s::Stinger, nv::Int64)
    status = ccall(
        dlsym(stinger_core_lib, "stinger_consistency_check"),
        Int32,
        (Ptr{Void}, Int64),
        s, nv
    )
    status == 0 #true if 0, else false
end
