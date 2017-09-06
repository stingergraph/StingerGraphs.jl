# StingerGraphs

StingerGraphs is a Julia wrapper around the [STINGER](https://github.com/stingergraph/stinger) library for processing streaming/dynamic graphs. This wrapper is built around the `dev` branch of the STINGER repository.

# Contents

```@contents
```

## Setup

If you have the `libstinger_core` shared library in a custom path, please configure
the environment variable `STINGER_LIB_PATH` with the path to the folder containing the
library.

## The Stinger type
The Stinger type can be used to create a new STINGER data structure. Due to the
use of variable length attributes in the C STINGER data structure, we are unable
to use a Julia type to directly map to a STINGER type (http://docs.julialang.org/en/release-0.4/manual/calling-c-and-fortran-code/#struct-type-correspondences).
So we use the C pointer handle to interact with the STINGER library in the implementation.

## Creating STINGER graphs

```julia
s = Stinger() #Creates a new datastructure
#Alternatively, to initialize a stinger graph with initial edges (stinger_set_initial_edges)
s = Stinger(5, 0, [0 for i=1:6], [i%5 for i=1:5], [2 for i=1:5], Int64[], Int64[], -2)
```

We have registered finalizers with Julia that automatically frees your STINGER
data structure, the next time the gc runs after it goes out of scope.

## Adding and Removing edges

Use the `insert_edge!` and `remove_edge!` to add and remove edges respectively.
They return the value of 1 on success.

```julia
s = Stinger(5, 0, [0 for i=1:6], [i%5 for i=1:5], [2 for i=1:5], Int64[], Int64[], -2)
insert_edge!(s, 0, 1, 4, 2, 2)
remove_edge!(s, 0, 1, 4)
```

## Consistency Checks

The STINGER graph can be checked for consistency using the `consistency_check`
function. It returns `true` if consistent or `false` if inconsistent.

## API Documentation

```@autodocs
Modules = [StingerGraphs]
Order   = [:type, :function]
```

