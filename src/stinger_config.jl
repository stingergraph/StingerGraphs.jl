export StingerConfig, stingerconfig

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

function stingerconfig(
    ;nv::Int64=0, nebs::Int64=0, netypes::Int64=0, nvtypes::Int64=0,
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

function generateconfig(nv::Int64; netypes::Int64=1, nvtypes::Int64=1)
    ##TODO :Find the exact sizeof and remove 64*3 etc
    #FIXME: Does not work nicely
    sz = maxmemsize() * 0.5 - (verticessize(nv)  + physmapsize(nv) +
        namessize(netypes) + namessize(nvtypes) + 8 * 3 + 8 * 3)
    nebs = floor(Int, sz / (64 + 8))
    return stingerconfig(nv=nv, nebs=nebs, netypes=netypes, nvtypes=nvtypes, no_resize=1)
end
