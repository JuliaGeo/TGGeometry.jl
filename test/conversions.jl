import GeoInterface as GI
using TGGeometry


function points_equal(p1, p2)
    return (GI.x(p1) == GI.x(p2)) && (GI.y(p1) == GI.y(p2))
end

function geoms_equal(g1, g2)
    if GI.ngeom(g1) != GI.ngeom(g2)
        return false
    end
    all(splat(points_equal), zip(GI.getpoint(g1), GI.getpoint(g2)))
end

@testset "Point round-trip" begin
    gi_point = GI.Point(1.0, 2.0)
    tg_geom = GI.convert(TGGeometry, gi_point)
    @test GI.getcoord(gi_point, 1) == GI.getcoord(tg_geom, 1)
    @test GI.getcoord(gi_point, 2) == GI.getcoord(tg_geom, 2)
end

@testset "LineString round-trip" begin
    gi_linestring = GI.LineString([(1.0, 2.0), (3.0, 4.0), (5.0, 6.0)])
    tg_geom = GI.convert(TGGeometry, gi_linestring)
    @test geoms_equal(gi_linestring, tg_geom)
end

@testset "Polygon round-trip" begin
    exterior = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0), (0.0, 0.0)]
    hole = [(2.0, 2.0), (8.0, 2.0), (8.0, 8.0), (2.0, 8.0), (2.0, 2.0)]
    gi_polygon = GI.Polygon([exterior, hole])
    tg_geom = GI.convert(TGGeometry, gi_polygon)
    @test geoms_equal(gi_polygon, tg_geom)
end

@testset "MultiPoint round-trip" begin
    gi_multipoint = GI.MultiPoint([(1.0, 2.0), (3.0, 4.0), (5.0, 6.0)])
    tg_geom = GI.convert(TGGeometry, gi_multipoint)
    @test geoms_equal(gi_multipoint, tg_geom)
end

@testset "MultiLineString round-trip" begin
    line1 = [(0.0, 0.0), (1.0, 1.0), (2.0, 2.0)]
    line2 = [(3.0, 3.0), (4.0, 4.0), (5.0, 5.0)]
    gi_multilinestring = GI.MultiLineString([line1, line2])
    tg_geom = GI.convert(TGGeometry, gi_multilinestring)
    @test geoms_equal(gi_multilinestring, tg_geom)
end

@testset "MultiPolygon round-trip" begin
    # First polygon with a hole
    poly1_exterior = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0), (0.0, 0.0)]
    poly1_hole = [(2.0, 2.0), (8.0, 2.0), (8.0, 8.0), (2.0, 8.0), (2.0, 2.0)]
    
    # Second polygon without holes
    poly2_exterior = [(20.0, 20.0), (30.0, 20.0), (30.0, 30.0), (20.0, 30.0), (20.0, 20.0)]
    
    gi_multipolygon = GI.MultiPolygon([[poly1_exterior, poly1_hole], [poly2_exterior]])
    tg_geom = GI.convert(TGGeometry, gi_multipolygon)
    
    @test GI.ngeom(gi_multipolygon) == GI.ngeom(tg_geom)
    
    for poly_idx in 1:GI.ngeom(gi_multipolygon)
        gi_poly = GI.getgeom(gi_multipolygon, poly_idx)
        tg_poly = GI.getgeom(tg_geom, poly_idx)
        
        @test GI.nring(gi_poly) == GI.nring(tg_poly)
        
        for ring_idx in 1:GI.nring(gi_poly)
            gi_ring = GI.getring(gi_poly, ring_idx)
            tg_ring = GI.getring(tg_poly, ring_idx)
            @test geoms_equal(gi_ring, tg_ring)
        end
    end
end
