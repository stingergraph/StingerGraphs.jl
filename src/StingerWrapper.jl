module StingerWrapper

# package code goes here
include("stinger_lib.jl")
include("stinger_graph.jl")
include("stinger_config.jl")
include("stinger_core.jl")
include("fields.jl")
include("traversal.jl")

include("algorithms/bfs.jl")
include("algorithms/kcore.jl")
include("generators/kronecker.jl")

end # module
