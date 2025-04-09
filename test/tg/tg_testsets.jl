using JSON3
import GeoFormatTypes as GFT, GeoInterface as GI
import WellKnownGeometry

import TGGeometry
using Test


TG_PRED_SYMBOL_TO_FUNCTION = Dict(
    [sym => getproperty(TGGeometry, sym) for sym in TGGeometry.TG_PREDICATES]
)

TG_IGNORE_LIST = Set([:crosses, :overlaps, :equals])

function run_testsets(json_file_path)
    testsets = JSON3.read(read(json_file_path))
    for i in eachindex(testsets)
        testset = testsets[i]
        # Skip any empty geometries
        any(testset.geoms) do geom
            !(geom isa String) || # some things are feature collections - TODO extend the parser function to call GeoJSON....
            contains(geom, "EMPTY") # if geom is empty, we just don't support that shit
        end && continue

        geoms = @. GFT.WellKnownText((GFT.Geom(),), String(testset.geoms))
        # TODO: this should be a ContextTestSet, BUT
        # that is not available in 1.6........
        # since I never expect these tests to fail I am fine with the potential noise.  
        # but in general - DO NOT do this massive testset nesting,
        # instead use context to avoid gigantic testset printing.
        @testset "testset_index = $i" begin 
            for (predname, results) in testset.predicates
                !haskey(TG_PRED_SYMBOL_TO_FUNCTION, predname) && continue
                predname in TG_IGNORE_LIST && continue
                predicate_f = TG_PRED_SYMBOL_TO_FUNCTION[predname]

                expected = first(results) == "T"

                @testset "predicate = $predname" begin
                    @test predicate_f(geoms[1], geoms[2]) == expected
                end
            end
        end
    end
end

@testset "All TG testsets" begin
    for file in filter(endswith(".jsonc"), readdir(joinpath(@__DIR__, "data"); join = true))
        filename = splitext(basename(file))[1]
        @testset "$filename" begin
            run_testsets(file)
        end
    end
end
