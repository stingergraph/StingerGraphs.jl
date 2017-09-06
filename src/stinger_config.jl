export StingerConfig, stingerconfig, generateconfig

"""
Used to set the configuration of the STINGER data structure.
"""
immutable StingerConfig
    nv::Int64
    nebs::Int64
    netypes::Int64
    nvtypes::Int64
    memory_size::Int64
    no_map_none_etype::Int8
    no_map_none_vtype::Int8
    no_resize::Int8
end

"""
Creates a `StingerConfig`.
"""
function stingerconfig(
    nv::Int64; nebs::Int64=0, netypes::Int64=0, nvtypes::Int64=0,
    memory_size::Int64=0, no_map_none_etype::Int64=0, no_map_none_vtype::Int64=0,
    no_resize::Int64=0)
    StingerConfig(nv, nebs, netypes, nvtypes, memory_size, no_map_none_etype, no_map_none_vtype, no_resize)
end

function maxmemsize()
    return ccall(dlsym(stinger_core_lib, "stinger_max_memsize"), UInt64, ())
end

function verticessize(nv::Int64)
    return ccall(dlsym(stinger_core_lib, "stinger_vertices_size"), UInt64, (Int64,), nv)
end

function physmapsize(nv::Int64)
    return ccall(dlsym(stinger_core_lib, "stinger_physmap_size"), UInt64, (Int64,), nv)
end

function namessize(ntypes::Int64)
    return ccall(dlsym(stinger_core_lib, "stinger_names_size"), UInt64, (Int64,), ntypes)
end

"""
Generates a config for the specified number and types of vertices and the number
of edge types. The generated config attempts to maximize the number of edge
blocks that can be allocated.
"""
function generateconfig(nv::Int64; netypes::Int64=1, nvtypes::Int64=1)
    sz = maxmemsize() * 0.5 - (verticessize(nv)  + physmapsize(nv) +
        namessize(netypes) + namessize(nvtypes) + 16 + 16)
    nebs = floor(Int, sz / (512 + 8))
    return stingerconfig(nv, nebs=nebs, netypes=netypes, nvtypes=nvtypes, no_resize=1)
end
