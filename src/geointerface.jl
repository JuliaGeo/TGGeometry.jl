import GeoInterface

# Basic trait implementations
GeoInterface.isgeometry(::tg_point) = true

GeoInterface.geomtrait(::tg_point) = GI.PointTrait()

# Coordinate access
GeoInterface.ncoord(::GI.PointTrait, p::tg_point) = 2
GeoInterface.getcoord(::GI.PointTrait, p::tg_point, i) = i == 1 ? p.x : p.y

GeoInterface.convert(::Type{tg_point}, ::GI.PointTrait, x) = tg_point(GI.x(x), GI.y(x))


# Helper to convert coordinates to tuples
point_to_tuple(p::tg_point) = (p.x, p.y)


# Geometry traits
function _trait_type(geom::Ptr{tg_geom})
    type = tg_geom_typeof(geom)
    if type == TG_POINT
        GeoInterface.PointTrait
    elseif type == TG_LINESTRING
        GeoInterface.LineStringTrait
    elseif type == TG_POLYGON
        GeoInterface.PolygonTrait
    elseif type == TG_MULTIPOINT
        GeoInterface.MultiPointTrait
    elseif type == TG_MULTILINESTRING
        GeoInterface.MultiLineStringTrait
    elseif type == TG_MULTIPOLYGON
        GeoInterface.MultiPolygonTrait
    elseif type == TG_GEOMETRYCOLLECTION
        GeoInterface.GeometryCollectionTrait
    else
        error("Unknown TG geometry type $type")
    end
end


"""
    TGGeom

A wrapper around a tg_geom pointer. Automatically handles memory management through a finalizer.
"""
mutable struct TGGeom{Trait}
    ptr::Ptr{tg_geom}

    function TGGeom{Trait}(ptr::Ptr{tg_geom}) where Trait <: GI.AbstractGeometryTrait
        # @assert _trait_type(ptr) == Trait # assume you know what you are talking about.
        # Check for errors in the geometry
        err = tg_geom_error(ptr)
        if err != C_NULL
            msg = unsafe_string(err)
            tg_geom_free(ptr)
            error("TG Error: $msg")
        end
        return new{Trait}(ptr)
    end
    function TGGeom(ptr::Ptr{tg_geom})
        # Check for errors in the geometry
        err = tg_geom_error(ptr)
        if err != C_NULL
            msg = unsafe_string(err)
            tg_geom_free(ptr)
            error("TG Error: $msg")
        end
        trait = _trait_type(ptr)
        # Create the wrapper and attach finalizer
        geom = new{trait}(ptr)
        finalizer(x -> tg_geom_free(x.ptr), geom)
        return geom
    end
end

# Prevent double-free issues when copying
# TODO: maybe we should use tg_geom_clone for Base.copy...

Base.copy(geom::TGGeom{Trait}) where Trait = TGGeom{Trait}(tg_geom_copy(geom.ptr)) # perform a deep copy here
Base.deepcopy(geom::TGGeom{Trait}) where Trait = TGGeom{Trait}(tg_geom_copy(geom.ptr)) # perform a deep copy here


# Pretty printing
function Base.show(io::IO, ::MIME"text/plain", geom::TGGeom{Trait}) where Trait
    print(io, "TGGeom{$(nameof(Trait))}")

    # TODO: the problem here is that the GeoInterface wrapper trait method
    # simply calls back into show for the child geometry, which is exactly what we don't want.
    # Since we don't have e.g. GeometryOps.tuples accessible in this package,
    # we'll have to either do this manually, or wait for GeoInterface to get a nice_show method
    # which others can utilize.
    # gi_show_result = sprint() do io
    #     show(io, MIME"text/plain"(), GI.Wrappers.geointerface_geomtype(Trait()){false, false}(geom))
    # end

    # print(io, gi_show_result[length("GeoInterface.Wrappers.$(nameof(Trait)){false, false}")+1:end])

end

# Basic trait implementations
GeoInterface.isgeometry(::TGGeom) = true
GeoInterface.ncoord(::GI.AbstractGeometryTrait, geom::TGGeom) = 2
GeoInterface.is3d(::GI.AbstractGeometryTrait, geom::TGGeom) = false
GeoInterface.ismeasured(::GI.AbstractGeometryTrait, geom::TGGeom) = false

GeoInterface.Extents.extent(geom::TGGeom) = convert(GI.Extents.Extent, tg_geom_rect(geom.ptr)) # see bottom of file for conversion

# Geometry traits
function GeoInterface.geomtrait(geom::TGGeom{Trait}) where Trait
    Trait()
end

# Point implementations
GeoInterface.ncoord(::GI.PointTrait, geom::TGGeom) = 2
function GeoInterface.getcoord(::GI.PointTrait, geom::TGGeom, i)
    p = tg_geom_point(geom.ptr)
    i == 1 ? p.x : p.y
end

# MultiPoint implementations
# This is only applicable to MultiPointTrait, not to other traits.
GeoInterface.ngeom(::GI.MultiPointTrait, geom::TGGeom{GI.MultiPointTrait}) = tg_geom_num_points(geom.ptr)
function GeoInterface.getgeom(::GI.MultiPointTrait, geom::TGGeom, i)
    p = tg_geom_point_at(geom.ptr, i-1)  # Convert to 0-based indexing
    p # return a TG point which is not a pointer, to make life faster.
end

# LineString implementations
GeoInterface.ngeom(::GI.LineStringTrait, geom::TGGeom) = tg_line_num_points(tg_geom_line(geom.ptr))
function GeoInterface.getgeom(::GI.LineStringTrait, geom::TGGeom, i)
    point = tg_line_point_at(tg_geom_line(geom.ptr), i-1)  # Convert to 0-based indexing
    point # return a TG point which is not a pointer, to make life faster.
end

# LinearRing implementations
GeoInterface.ngeom(::GI.LinearRingTrait, geom::TGGeom{GI.LinearRingTrait}) = tg_ring_num_points(geom.ptr)
function GeoInterface.getgeom(::GI.LinearRingTrait, geom::TGGeom{GI.LinearRingTrait}, i)
    point = tg_ring_point_at(geom.ptr, i-1)  # Convert to 0-based indexing
    point # return a TG point which is not a pointer, to make life faster.
end

# MultiLineString implementations
GeoInterface.ngeom(::GI.MultiLineStringTrait, geom::TGGeom) = tg_geom_num_lines(geom.ptr)
function GeoInterface.getgeom(::GI.MultiLineStringTrait, geom::TGGeom, i)
    line = tg_geom_line_at(geom.ptr, i-1)  # Convert to 0-based indexing
    TGGeom{GeoInterface.LineStringTrait}(tg_geom_new_linestring(line))
end

# Polygon implementations
function GeoInterface.ngeom(::GI.PolygonTrait, geom::TGGeom)
    poly = tg_geom_poly(geom.ptr)
    1 + tg_poly_num_holes(poly)  # Exterior ring + holes
end

function GeoInterface.getgeom(::GI.PolygonTrait, geom::TGGeom, i)
    poly = tg_geom_poly(geom.ptr)
    ring = if i == 1
        tg_poly_exterior(poly)
    else
        tg_poly_hole_at(poly, i-2)  # Convert to 0-based indexing for holes
    end
    TGGeom{GeoInterface.LinearRingTrait}(tg_geom_clone(ring))  # Rings are treated as closed linestrings
end

# MultiPolygon implementations
GeoInterface.ngeom(::GI.MultiPolygonTrait, geom::TGGeom) = tg_geom_num_polys(geom.ptr)
function GeoInterface.getgeom(::GI.MultiPolygonTrait, geom::TGGeom, i)
    poly = tg_geom_poly_at(geom.ptr, i-1)  # Convert to 0-based indexing
    TGGeom{GeoInterface.PolygonTrait}(tg_geom_new_polygon(poly))
end

# GeometryCollection implementations
GeoInterface.ngeom(::GI.GeometryCollectionTrait, geom::TGGeom) = tg_geom_num_geometries(geom.ptr)
function GeoInterface.getgeom(::GI.GeometryCollectionTrait, geom::TGGeom, i)
    # Here, we have no idea what the type of the geometry is, so we just return a TGGeom.
    # The constructor will figure out the type.

    # Yes, this is a bit type unstable.  But it's a small union, so I think it's fine.
    TGGeom(tg_geom_geometry_at(geom.ptr, i-1) |> tg_geom_clone)  # Convert to 0-based indexing
end

# Conversion methods
geointerface_geomtype(::GI.PointTrait) = tg_point # special case points, since they can be kept in Julia.
geointerface_geomtype(::GI.MultiPointTrait) = TGGeom{GI.MultiPointTrait}
geointerface_geomtype(::GI.LineStringTrait) = TGGeom{GI.LineStringTrait}
geointerface_geomtype(::GI.MultiLineStringTrait) = TGGeom{GI.MultiLineStringTrait}
geointerface_geomtype(::GI.PolygonTrait) = TGGeom{GI.PolygonTrait}
geointerface_geomtype(::GI.MultiPolygonTrait) = TGGeom{GI.MultiPolygonTrait}
geointerface_geomtype(::GI.GeometryCollectionTrait) = TGGeom{GI.GeometryCollectionTrait}


# These are the fallback methods, which will dispatch to the correct convert method
# based on the trait of the input geometry.

function GeoInterface.convert(::Type{TGGeom}, geom)
    trait = GeoInterface.geomtrait(geom)
    GeoInterface.convert(TGGeom{typeof(trait)}, trait, geom)
end

function GeoInterface.convert(::Type{TGGeom}, geom::TGGeom)
    return geom
end

function GeoInterface.convert(::Type{TGGeom}, trait::GI.AbstractGeometryTrait, geom)
    GeoInterface.convert(TGGeom{trait}, trait, geom)
end

# Point conversion
function GeoInterface.convert(::Type{TGGeom{GI.PointTrait}}, ::GI.PointTrait, geom)
    coords = GI.x(geom), GI.y(geom)
    point = tg_point(coords[1], coords[2])
    TGGeom{GI.PointTrait}(tg_geom_new_point(point))
end

# MultiPoint conversion
function GeoInterface.convert(::Type{TGGeom{GI.MultiPointTrait}}, ::GI.MultiPointTrait, geom)
    points = [tg_point(GI.x(p), GI.y(p)) for p in GI.getpoint(geom)]
    return TGGeom{GI.MultiPointTrait}(tg_geom_new_multipoint(points, length(points)))
end

# LineString conversion
function GeoInterface.convert(::Type{TGGeom{GI.LineStringTrait}}, ::GI.LineStringTrait, geom)
    points = [tg_point(GI.x(p), GI.y(p)) for p in GI.getpoint(geom)]
    line = tg_line_new(points, length(points))
    # Note: no need to free the line here, since the TGGeom finalizer will do it.
    TGGeom{GI.LineStringTrait}(line)
end

# LinearRing conversion
function GeoInterface.convert(::Type{TGGeom{GI.LinearRingTrait}}, ::GI.LinearRingTrait, geom)
    points = [tg_point(GI.x(p), GI.y(p)) for p in GI.getpoint(geom)]
    ring = tg_ring_new(points, length(points))
    # Note: no need to free the ring here, since the TGGeom finalizer will do it.
    TGGeom{GI.LinearRingTrait}(ring)
end

# MultiLineString conversion
function GeoInterface.convert(::Type{TGGeom{GI.MultiLineStringTrait}}, ::GI.MultiLineStringTrait, geom)
    n = GI.ngeom(geom)
    lines = Vector{Ptr{tg_line}}(undef, n)
    for (i, ls) in enumerate(GI.getgeom(geom))
        points = tg_point[tg_point(GI.x(p), GI.y(p)) for p in GI.getpoint(ls)]
        lines[i] = tg_line_new(points, length(points))
    end
    result = TGGeom{GI.MultiLineStringTrait}(tg_geom_new_multilinestring(lines, n))
    # Note that we only do this when constructing mutable intermediate geometries.
    for line in lines
        tg_line_free(line) # decrement the reference count on the line
    end
    return result
end

# Polygon conversion
function GeoInterface.convert(::Type{TGGeom{GI.PolygonTrait}}, ::GI.PolygonTrait, geom)
    # Convert exterior ring
    exterior = _convert_ring(GI.getring(geom, 1))
    
    # Convert holes
    nholes = GI.nring(geom) - 1
    holes = Vector{Ptr{tg_ring}}(undef, nholes)
    for i in 1:nholes
        holes[i] = _convert_ring(GI.getring(geom, i + 1))
    end
    
    # Create polygon
    result = TGGeom{GI.PolygonTrait}(tg_geom_new_polygon(tg_poly_new(exterior, holes, nholes)))

    # Note that we only do this when constructing mutable intermediate geometries.
    tg_poly_free(exterior) # decrement the reference count on the exterior
    for hole in holes
        tg_ring_free(hole) # decrement the reference count on the hole
    end
    return result
end

# Helper function for converting rings
function _convert_ring(ring)
    points = [tg_point(GI.x(coord), GI.y(coord)) for coord in GI.getpoint(ring)]
    tg_ring_new(points, length(points))
end

# MultiPolygon conversion
function GeoInterface.convert(::Type{TGGeom{GI.MultiPolygonTrait}}, ::GI.MultiPolygonTrait, geom)
    n = GI.ngeom(geom)
    polys = Vector{Ptr{tg_poly}}(undef, n)
    
    for i in 1:n
        polygon = GI.getgeom(geom, i)
        # Convert exterior ring
        exterior = _convert_ring(GI.getring(polygon, 1))
        
        # Convert holes
        nholes = GI.nhole(polygon)
        holes = if nholes > 0
            _holes = Vector{Ptr{tg_ring}}(undef, nholes)
            for j in 1:nholes
                _holes[j] = _convert_ring(GI.getring(polygon, j + 1))
            end
            _holes
        else
            C_NULL
        end
        
        polys[i] = tg_poly_new(exterior, holes, nholes)

        # Note that we only do this when constructing mutable intermediate geometries.
        tg_ring_free(exterior) # decrement the reference count on the exterior  
        if nholes > 0
            for hole in holes
                tg_ring_free(hole) # decrement the reference count on the hole
            end
        end
    end
    
    result = TGGeom{GI.MultiPolygonTrait}(tg_geom_new_multipolygon(polys, n))

    # Note that we only do this when constructing mutable intermediate geometries.
    for poly in polys
        tg_poly_free(poly) # decrement the reference count on the polygon
    end
    return result
end

# GeometryCollection conversion
function GeoInterface.convert(::Type{TGGeom{GI.GeometryCollectionTrait}}, ::GI.GeometryCollectionTrait, geom)
    n = GI.ngeom(geom)
    geoms = Vector{Ptr{tg_geom}}(undef, n)
    
    for i in 1:n
        subgeom = GI.getgeom(geom, i)
        # Convert each sub-geometry and store its pointer
        converted = GeoInterface.convert(TGGeom, subgeom)
        # No need to clone the geometry to avoid ownership issues
        # since the new geometrycollection constructor will take ownership of it
        geoms[i] = converted.ptr
        # The original converted geometry will be freed normally
        # when it goes out of scope, as we're using a clone
    end
    
    TGGeom{GI.GeometryCollectionTrait}(tg_geom_new_geometrycollection(geoms, n))
end


# Finally, we implement some conversions from extents to tg_rect and back.

function Base.convert(::Type{tg_rect}, extent::GI.Extents.Extent)
    return tg_rect(tg_point(extent.X[1], extent.Y[1]), tg_point(extent.X[2], extent.Y[2]))
end

function Base.convert(::Type{GI.Extents.Extent}, rect::tg_rect)
    return GI.Extents.Extent(X = (rect.min.x, rect.max.x),  Y = (rect.min.y, rect.max.y))
end