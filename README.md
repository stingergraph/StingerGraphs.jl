# StingerGraphs

[![Build Status](https://travis-ci.org/stingergraph/StingerGraphs.jl.svg?branch=master)](https://travis-ci.org/stingergraph/StingerGraphs.jl)

This is a Julia wrapper around the [STINGER](https://github.com/stingergraph/stinger) library for processing streaming/dynamic graphs. This wrapper focuses on the `dev` branch of the stinger repository.

See the docs (https://stingergraph.github.io/StingerGraphs.jl/latest/) for more details.

## Getting Started

To install this package run `Pkg.add("StingerGraphs")` from the Julia prompt.

To get the latest development version run:
```julia
julia> Pkg.clone("git@github.com:stingergraph/StingerGraphs.jl.git")
INFO: Cloning StingerGraphs from git@github.com:stingergraph/StingerGraphs.jl.git
INFO: Computing changes...
INFO: No packages to install, update or remove

julia> Pkg.build("StingerGraphs")
INFO: Building StingerGraphs
INFO: Attempting to Create directory /Users/jfairbanks6/.julia/v0.6/StingerGraphs/deps/downloads
INFO: Downloading file https://github.com/rohitvarkey/stinger/archive/stingergraphs.jl_v0.0.1.tar.gz
...
```
This will build the stinger library in the `/deps` folder and make it availble on the Julia load path.

To use the package:

```julia
using StingerGraphs
s = Stinger()
# edges have a type, source, destination, weight, and timestamp
insert_edge!(s, 0, 1, 2, 1, 1)
insert_edge!(s, 0, 1, 4, 1, 2)
insert_edge!(s, 0, 1, 5, 1, 3)
insert_edge!(s, 0, 3, 4, 1, 4)
f(e,i,j) = println("neighbor $(e.neighbor) weight $(e.weight) tfirst $(e.timefirst) trecent $(e.timerecent) source $i etype $j")
foralledges(f,s,1)
```

which will produce the following output:

```
julia> using StingerGraphs

julia> s = Stinger()
Sep 14 12:11:30  stinger[27520] <Warning>: stinger_new_full 827: Resizing stinger to fit into memory (detected as 8589934592)
StingerGraphs.Stinger(Ptr{Void} @0x000000051e7ba000)

julia> # edges have a type, source, destination, weight, and timestamp
       insert_edge!(s, 0, 1, 2, 1, 1)
1

julia> insert_edge!(s, 0, 1, 4, 1, 2)
1

julia> insert_edge!(s, 0, 1, 5, 1, 3)
1

julia> insert_edge!(s, 0, 3, 4, 1, 4)
1

julia> f(e,i,j) = println("neighbor $(e.neighbor) weight $(e.weight) tfirst $(e.timefirst) trecent $(e.timerecent) source $i etype $j")
f (generic function with 1 method)

julia> foralledges(f,s,1)
neighbor 4611686018427387906 weight 1 tfirst 1 trecent 1 source 1 etype 0
neighbor 4611686018427387908 weight 1 tfirst 2 trecent 2 source 1 etype 0
neighbor 4611686018427387909 weight 1 tfirst 3 trecent 3 source 1 etype 0
```
