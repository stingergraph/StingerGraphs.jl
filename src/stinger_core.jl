import Base.Libdl: dlopen, dlsym
import Base: unsafe_convert

export Stinger,
stinger_core_lib,
remove_edge!,
insert_edge!,
remove_edges!,
insert_edges!,
consistency_check,
outdegree,
getsuccessors,
edgeweight

if "STINGER_LIB_PATH" in keys(ENV)
    const stinger_core_lib = dlopen(joinpath(ENV["STINGER_LIB_PATH"],"libstinger_core"))
else
    const stinger_core_lib = dlopen("libstinger_core")
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

"""Use this to get a `StingerGraph` representation of your `Stinger` graph. This
representation will not be kept in sync with the graph. If you make changes,
you will need to call this again to load the graph with the new attributes."""
loadstingergraph(s::Stinger) = unsafe_load(convert(Ptr{StingerGraph}, s.handle))

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

function insert_edges!(s::Stinger, edges::AbstractArray, numedges::Integer)
    m = size(edges,2);
    numedges <= m || throw(DimensionMismatch("requested to insert too many edges $m < $numedges"))
    size(edges, 1) == 5 || throw(DimensionMismatch("Wrong input format should be 5×numedges"))
    for i in 1:numedges
        insert_edge!(s, edges[1,i], edges[2,i], edges[3,i], edges[4,i], edges[5,i])
    end
end

function remove_edges!(s::Stinger, edges::AbstractArray, numedges::Integer)
    size(edges, 1) == 5 || throw(DimensionMismatch("Input format is 5×numedges (etype, src, dst, weight, times)"))
    for i in 1:numedges
        remove_edge!(s, 0, edges[2,i], edges[3,i])
    end
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

"Return outdegree of vertex index."
function outdegree(s::Stinger, src::Int64)
    #TODO: Add check if vertex exists in the graph
    ccall(
        dlsym(stinger_core_lib, "stinger_outdegree_get"),
        Int64,
        (Ptr{Void}, Int64),
        s, src
    )
end

"Return a `Vector` of indices representing the successors of the source"
function getsuccessors(s::Stinger, src::Int64)
    #Ideally, allocating a buffer would be preffered.
    #This makes 2 calls to outdegree - one from here and one from inside C
    outdeg = outdegree(s, src)
    vertexneighbors = zeros(Int64, outdeg)
    if outdeg==0
        return vertexneighbors
    end
    ccall(
        dlsym(stinger_core_lib, "stinger_gather_successors"),
        Void,
        (
            Ptr{Void}, #Stinger instance
            Int64, #Source vertex
            Ptr{Int64}, #Outdegree variable
            Ptr{Int64}, #Output buffer
            Ptr{Int64}, #weight
            Ptr{Int64}, #timefirst
            Ptr{Int64}, #timerecent
            Ptr{Int64}, #type
            Int64 #Max Length
        ),
        s,
        src,
        pointer_from_objref(outdeg),
        vertexneighbors,
        C_NULL,
        C_NULL,
        C_NULL,
        C_NULL,
        typemax(Int64)
    )
    vertexneighbors
end

"Return the weight of the edge. If it doesn't exist return 0."
function edgeweight(s::Stinger, src::Int64, dst::Int64, etype::Int64)
    ccall(
        dlsym(stinger_core_lib, "stinger_edgeweight"),
        Int64,
        (Ptr{Void}, Int64, Int64, Int64),
        s, src, dst, etype
    )
end
