using BinDeps

@BinDeps.setup

libstinger = library_dependency("libstinger")

provides(Sources,
    URI("https://github.com/rohitvarkey/stinger/archive/stingergraphs.jl_v0.0.1.tar.gz"),
    libstinger)

stingerbuilddir = joinpath(BinDeps.depsdir(libstinger), "build")
provides(BuildProcess,
    (@build_steps begin
        GetSources(libstinger)
        CreateDirectory(stingerbuilddir)
        @build_steps begin
            ChangeDirectory(stingerbuilddir)
            `cmake ..`
            `make`
        end
    end), libstinger)

@BinDeps.install Dict(:libstinger => :libstinger)
