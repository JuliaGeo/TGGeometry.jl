using TGGeometry
using Test

import GeoInterface as GI
using GeoInterface: Extent

@testset "TGGeometry.jl" begin
    # Write your tests here.
    @testset "Conversion" begin
        
    end
    @testset "Predicates work on GI geometry" begin
    end
    @testset "Geometry with rect intersection" begin
        # create a multi-point and a rectangle
        geom = GI.GeometryCollection([GI.Point(1.0, 1.0), GI.Point(2.0, 2.0)])
        rect = Extent(X=(0.0, 2.0), Y=(0.0, 2.0))
        @test TGGeometry.intersects(geom, rect) == true
    end
    @testset "Rect with point intersection" begin
        # create a point and a rectangle
        point = (1.0, 1.0)
        rect = Extent(X=(0.0, 2.0), Y=(0.0, 2.0))
        @test TGGeometry.intersects(point, rect) == true

        point = (10.0, 10)
        @test TGGeometry.intersects(point, rect) == false
    end
    @testset "Rect with rect intersection" begin
        # create two extents and call TGGeometry.intersects on them
        # Create two rectangles that overlap
        rect1 = Extent(X=(0.0, 10.0), Y=(0.0, 10.0))
        rect2 = Extent(X=(5.0, 15.0), Y=(5.0, 15.0))
        @test TGGeometry.intersects(rect1, rect2) == true
        
        # Create two rectangles that don't overlap
        rect3 = Extent(X=(0.0, 5.0), Y=(0.0, 5.0))
        rect4 = Extent(X=(6.0, 10.0), Y=(6.0, 10.0))
        @test TGGeometry.intersects(rect3, rect4) == false
        
        # Create two rectangles that touch at a point
        rect5 = Extent(X=(0.0, 5.0), Y=(0.0, 5.0))
        rect6 = Extent(X=(5.0, 10.0), Y=(5.0, 10.0))
        @test TGGeometry.intersects(rect5, rect6) == true
        
        # Create two rectangles where one contains the other
        rect7 = Extent(X=(0.0, 10.0), Y=(0.0, 10.0))
        rect8 = Extent(X=(2.0, 8.0), Y=(2.0, 8.0))
        @test TGGeometry.intersects(rect7, rect8) == true
    end
end
