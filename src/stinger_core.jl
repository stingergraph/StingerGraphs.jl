import Base.Libdl: dlopen, dlsym

export Stinger

stinger_core_lib = dlopen("/Users/rohitvarkey/Code/gatech/stinger/build/lib/libstinger_core.dylib")

type Stinger
    s::Ptr{Void}

    # To allow for maintaining multiple references to the same stinger data structure
    function Stinger(x::Ptr{Void})
        s = new(x)
        finalizer(s, stinger_free)
        s
    end

    #Default constructor to create a Stinger data structure
    function Stinger()
        s = new(ccall(dlsym(stinger_core_lib, "stinger_new"), Ptr{Void}, ()))
        finalizer(s, stinger_free)
        s
    end
end

#Intialize a new Stinger data structure with the ccall
Stinger() = Stinger(ccall(dlsym(stinger_core_lib, "stinger_new"), Ptr{Void}, ()))

function stinger_free(x::Stinger)
    ccall(dlsym(stinger_core_lib, "stinger_free"), Ptr{Void}, (Ptr{Void},), x.s)
end
