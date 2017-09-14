# StingerGraphs

[![Build Status](https://travis-ci.org/stingergraph/StingerGraphs.jl.svg?branch=master)](https://travis-ci.org/stingergraph/StingerGraphs.jl)

This is a Julia wrapper around the [STINGER](https://github.com/stingergraph/stinger) library for processing streaming/dynamic graphs. This wrapper focuses on the `dev` branch of the stinger repository.

See the docs (https://stingergraph.github.io/StingerGraphs.jl/latest/) for more details.

## Getting Started

To install this package run

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
