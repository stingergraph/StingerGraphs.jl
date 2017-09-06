using BinDeps

@BinDeps.setup

libstinger_core = library_dependency("libstinger_core")

provides(Sources,
    URI("https://github.com/rohitvarkey/stinger/archive/stingergraphs.jl_v0.0.1.tar.gz"),
    libstinger_core, unpacked_dir = "stinger-stingergraphs.jl_v0.0.1")

stingerbuilddir = joinpath(BinDeps.depsdir(libstinger_core), "src", "stinger-stingergraphs.jl_v0.0.1", "build")
provides(BuildProcess,
    (@build_steps begin
        GetSources(libstinger_core)
        CreateDirectory(stingerbuilddir)
        @build_steps begin
            ChangeDirectory(stingerbuilddir)
            `cmake ..`
            `make`
        end
    end), libstinger_core)

@BinDeps.install Dict(:libstinger_core => :libstinger_core)
