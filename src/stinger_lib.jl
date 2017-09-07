import Base.Libdl: dlopen
export stinger_core_lib, stinger_alg_lib

if "STINGER_LIB_PATH" in keys(ENV)
    const stinger_core_lib = dlopen(joinpath(ENV["STINGER_LIB_PATH"],"libstinger_core"))
    const stinger_alg_lib = dlopen(joinpath(ENV["STINGER_LIB_PATH"],"libstinger_alg"))
else
    basedir = joinpath(dirname(@__DIR__), "deps", "usr", "lib")
    const stinger_core_lib = dlopen(joinpath(basedir, "libstinger_core"))
    const stinger_core_alg = dlopen(joinpath(basedir, "libstinger_alg"))
end
