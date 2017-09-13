# StingerGraphs

StingerGraphs is a Julia wrapper around the [STINGER](https://github.com/stingergraph/stinger) library for processing streaming/dynamic graphs. This wrapper is built around the `dev` branch of the STINGER repository.

# Contents

```@contents
```

# Installation

```julia
Pkg.clone("https://github.com/stingergraph/UnsafeAtomics.jl")
Pkg.clone("https://github.com/stingergraph/StingerGraphs.jl")
Pkg.build("StingerGraphs")
```

## STINGER version

### Default version

By default, the package will try to download and build its own version of STINGER.
The version downloaded along with the package is the latest release found
[here](https://github.com/rohitvarkey/stinger/releases). It follows the `dev`
branch of STINGER.

### Custom STINGER version

If you wish to use a different version of STINGER, you can set the environment
variable `STINGER_LIB_PATH` with the path to the folder containing the
shared library `libstinger_core` and `libstinger_alg`.

# Guide

## The Stinger type
The Stinger type can be used to create a new STINGER data structure. Due to the
use of variable length attributes in the C STINGER data structure, we are unable
to use a Julia type to directly map to a STINGER type (http://docs.julialang.org/en/release-0.4/manual/calling-c-and-fortran-code/#struct-type-correspondences).
So we use the C pointer handle to interact with the STINGER library in the implementation.

## Creating STINGER graphs

```julia
julia> s = Stinger() # Creates a new STINGER
StingerGraphs.Stinger(Ptr{Void} @0x000000012317e000)
```

We have registered finalizers with Julia that automatically frees your STINGER
data structure, the next time the GC runs after it goes out of scope.

## Adding and Removing edges

Use the `insert_edge!` and `remove_edge!` to add and remove edges respectively.
They return the value of 1 on success.

```julia
julia> s = Stinger()
StingerGraphs.Stinger(Ptr{Void} @0x000000012317e000)
julia> insert_edge!(s, 0, 1, 4, 2, 2)
1

julia> remove_edge!(s, 0, 1, 4)
1
```

`insert_edges!` and `remove_edges!` can be used to add or remove multiple edges.

## Iterating through the edges

Use `foralledges` to iterate through the edges of a vertex. The `edgeparse`
function can help parse the edge and create a `StingerEdge`.

```julia
julia> foralledges(s, 1) do edge, src, etype
           direction, neighbor = edgeparse(edge)
           println("$direction, $neighbor, $etype")
       end
2, 4, 0
```

## BFS

`bfs` allows BFS to be run on Stinger graphs. Serial and parallel versions of the
algorithm are available. Please check the API docs for more details.

```julia
julia> s = Stinger()
StingerGraphs.Stinger(Ptr{Void} @0x000000012317e000)
julia> for i=1:5
           insert_edge!(s, 0, i, i+1, 1)
       end
julia> bfs(s, 1, 7)
7-element Array{Int64,1}:
    -2
    -1
    1
    2
    3
    4
    5
```

## K-core

`kcore` runs k-core decompositions on the graph.

```julia
julia> labels, counts = kcore(s, 7)
([0, 1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0, 0])
```

## Consistency Checks

The STINGER graph can be checked for consistency using the `consistency_check`
function. It returns `true` if consistent or `false` if inconsistent.

```julia
julia> consistency_check(s, 1) # number of vertices.
true
```

# API Documentation

```@autodocs
Modules = [StingerGraphs]
Order   = [:type, :function]
```
