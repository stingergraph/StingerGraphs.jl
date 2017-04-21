import Base.Libdl: dlopen
export stinger_core_lib, stinger_alg_lib, dyno_stinger_utils_lib

if "STINGER_LIB_PATH" in keys(ENV)
    const stinger_core_lib = dlopen(joinpath(ENV["STINGER_LIB_PATH"],"libstinger_core"))
    const stinger_alg_lib = dlopen(joinpath(ENV["STINGER_LIB_PATH"],"libstinger_alg"))
else
    const stinger_core_lib = dlopen("libstinger_core")
    const stinger_core_alg = dlopen("libstinger_alg")
end

if "DYNOGRAPH_PATH" in keys(ENV)
    const dyno_stinger_utils_lib = dlopen(joinpath(ENV["DYNOGRAPH_PATH"],"libdynograph_stinger_utils"))
else
    const dyno_stinger_utils_lib = dlopen("libdynograph_stinger_utils")
end
