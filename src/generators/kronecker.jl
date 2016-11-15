export kronecker

"""
Generates edges for a Kronecker generator graph. Returns an array of 2 rows
with 1st being the start edge and 2nd row having the end edge.
"""
function kronecker(
    scale::Int64,
    edgefactor::Int64;
    a::Float64=0.57,
    b::Float64=0.19,
    c::Float64 = 0.19
    )
#Ported from https://gitorious.org/graph500/graph500?p=graph500:graph500.git;a=blob;f=octave/kronecker_generator.m;h=064b6d4f42194cc95ec4ab375dcbee7c3243b233;hb=01a32a9c16994c3cf30bbf4caabf9be128379416.
    n = 2 ^ scale
    m = edgefactor * n
    a,b,c = 0.57, 0.19, 0.19
    ij = ones(Int64, 2, m)
    ab = a + b
    cnorm = c/(1-ab)
    anorm = a/ab

    for ib in 1:scale
        ii_bit = rand(1, m) .> ab
        jj_bit = rand(1, m) .> ( cnorm * ii_bit + anorm * !(ii_bit) )
        ij = ij .+ 2^(ib-1) .* [ii_bit; jj_bit]
    end

    p = randperm(n)
    ij = p[ij]

    p = randperm(m)
    ij = ij[:, p]

    return ij .- 1 #Convert to zero index for Stinger
end
