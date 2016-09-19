using StingerWrapper
using BenchmarkTools
using JLD
using FileIO

function bench(filename)
    s = Stinger()
    fields = [
        max_nv, max_neblock, max_netypes, max_nvtypes, num_insertions,
        num_deletions, num_insertions_last_batch, num_deletions_last_batch
    ]


    getrng = srand(1)

    getbench = @benchmarkable $s[f] samples=10000000  seconds=10 setup=(f=rand($getrng, $fields))

    setrng = srand(2)
    setbench = @benchmarkable $s[f]=val samples=10000000 setup=f,val=rand($setrng, $fields),rand($setrng,0:1000) seconds=10#For a reasonable run time

    info("Running getbench")
    gettrial = run(getbench)
    info("Running setbench")
    settrial = run(setbench)

    jldopen(filename, "w") do f
        write(f, "gettrial", gettrial)
        write(f, "settrial", settrial)
    end

    return gettrial, settrial
end
