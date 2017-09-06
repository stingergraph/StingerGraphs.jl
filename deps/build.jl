using BinDeps

@BinDeps.setup

libstinger_core = library_dependency("libstinger_core")
libstinger_alg = library_dependency("libstinger_alg")

provides(Sources,
    URI("https://github.com/rohitvarkey/stinger/archive/stingergraphs.jl_v0.0.1.tar.gz"),
    [libstinger_core, libstinger_alg], unpacked_dir = "stinger-stingergraphs.jl_v0.0.1")

stingerbuilddir = joinpath(BinDeps.depsdir(libstinger_core), "src", "stinger-stingergraphs.jl_v0.0.1", "build")
prefix = joinpath(BinDeps.depsdir(libstinger_core), "usr")
provides(BuildProcess,
    (@build_steps begin
        GetSources(libstinger_core)
        CreateDirectory(stingerbuilddir)
        CreateDirectory(joinpath(prefix, "lib"))
        @build_steps begin
            ChangeDirectory(stingerbuilddir)
            `cmake ..`
            `make`
            `ls lib/`
            FileRule(joinpath(prefix, "lib" , "libstinger_core.$(Base.Libdl.dlext)"), @build_steps begin
                `cp lib/libstinger_core.$(Base.Libdl.dlext) $prefix/lib/`
            end)
            FileRule(joinpath(prefix, "lib" , "libstinger_alg.$(Base.Libdl.dlext)"), @build_steps begin
                `cp lib/libstinger_alg.$(Base.Libdl.dlext) $prefix/lib/`
            end)
        end
    end), [libstinger_core, libstinger_alg])

@BinDeps.install Dict(
    :libstinger_core => :libstinger_core,
    :libstinger_alg => :libstinger_alg)
