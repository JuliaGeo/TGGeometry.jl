using Clang.Generators
# using PROJ_jll: artifact_dir
using JuliaFormatter: format




cd(@__DIR__)

artifact_dir = joinpath(@__DIR__, "..", "..", "tg") 

include_dir = normpath(artifact_dir,#= "include"=#)

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

headers = [joinpath(include_dir, "tg.h")]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx, BUILDSTAGE_NO_PRINTING)
build!(ctx, BUILDSTAGE_PRINTING_ONLY)

# run JuliaFormatter on the whole package
format(joinpath(@__DIR__, ".."))
