module TGGeometry

# Write your package code here.

using Libdl, CEnum

import GeoInterface as GI
import GeoInterface

const libtg = joinpath(@__DIR__, "..", "..", "tg", "libtg.so")

include("libtg.jl")
include("geointerface.jl")
include("predicates.jl")

export TGGeom, tg_point

# @static if VERSION >= v"1.11"
#     include("public.jl")
# end

end
