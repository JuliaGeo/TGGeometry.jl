"""
    tg_point

The base point type used for all geometries.

# See also
PointFuncs
"""
struct tg_point
    x::Cdouble
    y::Cdouble
end

"""
    tg_segment

The base segment type used in [`tg_line`](@ref) and [`tg_ring`](@ref) for joining two vertices.

# See also
SegmentFuncs
"""
struct tg_segment
    a::tg_point
    b::tg_point
end

"""
    tg_rect

A rectangle defined by a minimum and maximum coordinates. Returned by the [`tg_geom_rect`](@ref)(), [`tg_ring_rect`](@ref)(), and other \\*\\_rect()  functions for getting a geometry's minumum bounding rectangle. Also used internally for geometry indexing.

# See also
RectFuncs
"""
struct tg_rect
    min::tg_point
    max::tg_point
end

const tg_line = Cvoid

const tg_ring = Cvoid

const tg_poly = Cvoid

const tg_geom = Cvoid

"""
    tg_geom_type

Geometry types.

All [`tg_geom`](@ref) are one of the following underlying types.

| Enumerator              | Note                                          |
| :---------------------- | :-------------------------------------------- |
| TG\\_POINT              | Point                                         |
| TG\\_LINESTRING         | LineString                                    |
| TG\\_POLYGON            | Polygon                                       |
| TG\\_MULTIPOINT         | MultiPoint, collection of points              |
| TG\\_MULTILINESTRING    | MultiLineString, collection of linestrings    |
| TG\\_MULTIPOLYGON       | MultiPolygon, collection of polygons          |
| TG\\_GEOMETRYCOLLECTION | GeometryCollection, collection of geometries  |
# See also
[`tg_geom_typeof`](@ref)(), [`tg_geom_type_string`](@ref)(), GeometryAccessors
"""
@cenum tg_geom_type::UInt32 begin
    TG_POINT = 1
    TG_LINESTRING = 2
    TG_POLYGON = 3
    TG_MULTIPOINT = 4
    TG_MULTILINESTRING = 5
    TG_MULTIPOLYGON = 6
    TG_GEOMETRYCOLLECTION = 7
end

"""
    tg_index

Geometry indexing options.

Used for polygons, rings, and lines to make the point-in-polygon and geometry intersection operations fast.

An index can also be used for efficiently traversing, searching, and  performing nearest-neighbor (kNN) queries on the segment using  tg\\_ring\\_index\\_*() and tg\\_ring\\_nearest() functions.

| Enumerator    | Note                                                            |
| :------------ | :-------------------------------------------------------------- |
| TG\\_DEFAULT  | default is TG\\_NATURAL or tg\\_env\\_set\\_default\\_index().  |
| TG\\_NONE     | no indexing available, or disabled.                             |
| TG\\_NATURAL  | indexing with natural ring order, for rings/lines               |
| TG\\_YSTRIPES | indexing using segment striping, rings only                     |
"""
@cenum tg_index::UInt32 begin
    TG_DEFAULT = 0
    TG_NONE = 1
    TG_NATURAL = 2
    TG_YSTRIPES = 3
end

"""
    tg_geom_new_point(point)

` GeometryConstructors Geometry constructors`

Functions for creating and freeing geometries.  @{
"""
function tg_geom_new_point(point)
    @ccall libtg.tg_geom_new_point(point::tg_point)::Ptr{tg_geom}
end

function tg_geom_new_linestring(line)
    @ccall libtg.tg_geom_new_linestring(line::Ptr{tg_line})::Ptr{tg_geom}
end

function tg_geom_new_polygon(poly)
    @ccall libtg.tg_geom_new_polygon(poly::Ptr{tg_poly})::Ptr{tg_geom}
end

function tg_geom_new_multipoint(points, npoints)
    @ccall libtg.tg_geom_new_multipoint(points::Ptr{tg_point}, npoints::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multilinestring(lines, nlines)
    @ccall libtg.tg_geom_new_multilinestring(lines::Ptr{Ptr{tg_line}}, nlines::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multipolygon(polys, npolys)
    @ccall libtg.tg_geom_new_multipolygon(polys::Ptr{Ptr{tg_poly}}, npolys::Cint)::Ptr{tg_geom}
end

function tg_geom_new_geometrycollection(geoms, ngeoms)
    @ccall libtg.tg_geom_new_geometrycollection(geoms::Ptr{Ptr{tg_geom}}, ngeoms::Cint)::Ptr{tg_geom}
end

function tg_geom_new_error(errmsg)
    @ccall libtg.tg_geom_new_error(errmsg::Cstring)::Ptr{tg_geom}
end

function tg_geom_clone(geom)
    @ccall libtg.tg_geom_clone(geom::Ptr{tg_geom})::Ptr{tg_geom}
end

function tg_geom_copy(geom)
    @ccall libtg.tg_geom_copy(geom::Ptr{tg_geom})::Ptr{tg_geom}
end

function tg_geom_free(geom)
    @ccall libtg.tg_geom_free(geom::Ptr{tg_geom})::Cvoid
end

"""
    tg_geom_typeof(geom)

` GeometryAccessors Geometry accessors`

Functions for accessing various information about geometries, such as getting the geometry type or extracting underlying components or coordinates. @{
"""
function tg_geom_typeof(geom)
    @ccall libtg.tg_geom_typeof(geom::Ptr{tg_geom})::tg_geom_type
end

function tg_geom_type_string(type)
    @ccall libtg.tg_geom_type_string(type::tg_geom_type)::Cstring
end

function tg_geom_rect(geom)
    @ccall libtg.tg_geom_rect(geom::Ptr{tg_geom})::tg_rect
end

function tg_geom_is_feature(geom)
    @ccall libtg.tg_geom_is_feature(geom::Ptr{tg_geom})::Bool
end

function tg_geom_is_featurecollection(geom)
    @ccall libtg.tg_geom_is_featurecollection(geom::Ptr{tg_geom})::Bool
end

function tg_geom_point(geom)
    @ccall libtg.tg_geom_point(geom::Ptr{tg_geom})::tg_point
end

function tg_geom_line(geom)
    @ccall libtg.tg_geom_line(geom::Ptr{tg_geom})::Ptr{tg_line}
end

function tg_geom_poly(geom)
    @ccall libtg.tg_geom_poly(geom::Ptr{tg_geom})::Ptr{tg_poly}
end

function tg_geom_num_points(geom)
    @ccall libtg.tg_geom_num_points(geom::Ptr{tg_geom})::Cint
end

function tg_geom_point_at(geom, index)
    @ccall libtg.tg_geom_point_at(geom::Ptr{tg_geom}, index::Cint)::tg_point
end

function tg_geom_num_lines(geom)
    @ccall libtg.tg_geom_num_lines(geom::Ptr{tg_geom})::Cint
end

function tg_geom_line_at(geom, index)
    @ccall libtg.tg_geom_line_at(geom::Ptr{tg_geom}, index::Cint)::Ptr{tg_line}
end

function tg_geom_num_polys(geom)
    @ccall libtg.tg_geom_num_polys(geom::Ptr{tg_geom})::Cint
end

function tg_geom_poly_at(geom, index)
    @ccall libtg.tg_geom_poly_at(geom::Ptr{tg_geom}, index::Cint)::Ptr{tg_poly}
end

function tg_geom_num_geometries(geom)
    @ccall libtg.tg_geom_num_geometries(geom::Ptr{tg_geom})::Cint
end

function tg_geom_geometry_at(geom, index)
    @ccall libtg.tg_geom_geometry_at(geom::Ptr{tg_geom}, index::Cint)::Ptr{tg_geom}
end

function tg_geom_extra_json(geom)
    @ccall libtg.tg_geom_extra_json(geom::Ptr{tg_geom})::Cstring
end

function tg_geom_is_empty(geom)
    @ccall libtg.tg_geom_is_empty(geom::Ptr{tg_geom})::Bool
end

function tg_geom_dims(geom)
    @ccall libtg.tg_geom_dims(geom::Ptr{tg_geom})::Cint
end

function tg_geom_has_z(geom)
    @ccall libtg.tg_geom_has_z(geom::Ptr{tg_geom})::Bool
end

function tg_geom_has_m(geom)
    @ccall libtg.tg_geom_has_m(geom::Ptr{tg_geom})::Bool
end

function tg_geom_z(geom)
    @ccall libtg.tg_geom_z(geom::Ptr{tg_geom})::Cdouble
end

function tg_geom_m(geom)
    @ccall libtg.tg_geom_m(geom::Ptr{tg_geom})::Cdouble
end

function tg_geom_extra_coords(geom)
    @ccall libtg.tg_geom_extra_coords(geom::Ptr{tg_geom})::Ptr{Cdouble}
end

function tg_geom_num_extra_coords(geom)
    @ccall libtg.tg_geom_num_extra_coords(geom::Ptr{tg_geom})::Cint
end

function tg_geom_memsize(geom)
    @ccall libtg.tg_geom_memsize(geom::Ptr{tg_geom})::Csize_t
end

function tg_geom_search(geom, rect, iter, udata)
    @ccall libtg.tg_geom_search(geom::Ptr{tg_geom}, rect::tg_rect, iter::Ptr{Cvoid}, udata::Ptr{Cvoid})::Cvoid
end

function tg_geom_fullrect(geom, min, max)
    @ccall libtg.tg_geom_fullrect(geom::Ptr{tg_geom}, min::Ptr{Cdouble}, max::Ptr{Cdouble})::Cint
end

"""
    tg_geom_equals(a, b)

` GeometryPredicates Geometry predicates`

Functions for testing the spatial relations of two geometries. @{
"""
function tg_geom_equals(a, b)
    @ccall libtg.tg_geom_equals(a::Ptr{tg_geom}, b::Ptr{tg_geom})::Bool
end

function tg_geom_intersects(a, b)
    @ccall libtg.tg_geom_intersects(a::Ptr{tg_geom}, b::Ptr{tg_geom})::Bool
end

function tg_geom_disjoint(a, b)
    @ccall libtg.tg_geom_disjoint(a::Ptr{tg_geom}, b::Ptr{tg_geom})::Bool
end

function tg_geom_contains(a, b)
    @ccall libtg.tg_geom_contains(a::Ptr{tg_geom}, b::Ptr{tg_geom})::Bool
end

function tg_geom_within(a, b)
    @ccall libtg.tg_geom_within(a::Ptr{tg_geom}, b::Ptr{tg_geom})::Bool
end

function tg_geom_covers(a, b)
    @ccall libtg.tg_geom_covers(a::Ptr{tg_geom}, b::Ptr{tg_geom})::Bool
end

function tg_geom_coveredby(a, b)
    @ccall libtg.tg_geom_coveredby(a::Ptr{tg_geom}, b::Ptr{tg_geom})::Bool
end

function tg_geom_touches(a, b)
    @ccall libtg.tg_geom_touches(a::Ptr{tg_geom}, b::Ptr{tg_geom})::Bool
end

function tg_geom_intersects_rect(a, b)
    @ccall libtg.tg_geom_intersects_rect(a::Ptr{tg_geom}, b::tg_rect)::Bool
end

function tg_geom_intersects_xy(a, x, y)
    @ccall libtg.tg_geom_intersects_xy(a::Ptr{tg_geom}, x::Cdouble, y::Cdouble)::Bool
end

"""
    tg_parse_geojson(geojson)

` GeometryParsing Geometry parsing`

Functions for parsing geometries from external data representations. It's recommended to use [`tg_geom_error`](@ref)() after parsing to check for errors. @{
"""
function tg_parse_geojson(geojson)
    @ccall libtg.tg_parse_geojson(geojson::Cstring)::Ptr{tg_geom}
end

function tg_parse_geojsonn(geojson, len)
    @ccall libtg.tg_parse_geojsonn(geojson::Cstring, len::Csize_t)::Ptr{tg_geom}
end

function tg_parse_geojson_ix(geojson, ix)
    @ccall libtg.tg_parse_geojson_ix(geojson::Cstring, ix::tg_index)::Ptr{tg_geom}
end

function tg_parse_geojsonn_ix(geojson, len, ix)
    @ccall libtg.tg_parse_geojsonn_ix(geojson::Cstring, len::Csize_t, ix::tg_index)::Ptr{tg_geom}
end

function tg_parse_wkt(wkt)
    @ccall libtg.tg_parse_wkt(wkt::Cstring)::Ptr{tg_geom}
end

function tg_parse_wktn(wkt, len)
    @ccall libtg.tg_parse_wktn(wkt::Cstring, len::Csize_t)::Ptr{tg_geom}
end

function tg_parse_wkt_ix(wkt, ix)
    @ccall libtg.tg_parse_wkt_ix(wkt::Cstring, ix::tg_index)::Ptr{tg_geom}
end

function tg_parse_wktn_ix(wkt, len, ix)
    @ccall libtg.tg_parse_wktn_ix(wkt::Cstring, len::Csize_t, ix::tg_index)::Ptr{tg_geom}
end

function tg_parse_wkb(wkb, len)
    @ccall libtg.tg_parse_wkb(wkb::Ptr{UInt8}, len::Csize_t)::Ptr{tg_geom}
end

function tg_parse_wkb_ix(wkb, len, ix)
    @ccall libtg.tg_parse_wkb_ix(wkb::Ptr{UInt8}, len::Csize_t, ix::tg_index)::Ptr{tg_geom}
end

function tg_parse_hex(hex)
    @ccall libtg.tg_parse_hex(hex::Cstring)::Ptr{tg_geom}
end

function tg_parse_hexn(hex, len)
    @ccall libtg.tg_parse_hexn(hex::Cstring, len::Csize_t)::Ptr{tg_geom}
end

function tg_parse_hex_ix(hex, ix)
    @ccall libtg.tg_parse_hex_ix(hex::Cstring, ix::tg_index)::Ptr{tg_geom}
end

function tg_parse_hexn_ix(hex, len, ix)
    @ccall libtg.tg_parse_hexn_ix(hex::Cstring, len::Csize_t, ix::tg_index)::Ptr{tg_geom}
end

function tg_parse_geobin(geobin, len)
    @ccall libtg.tg_parse_geobin(geobin::Ptr{UInt8}, len::Csize_t)::Ptr{tg_geom}
end

function tg_parse_geobin_ix(geobin, len, ix)
    @ccall libtg.tg_parse_geobin_ix(geobin::Ptr{UInt8}, len::Csize_t, ix::tg_index)::Ptr{tg_geom}
end

function tg_parse(data, len)
    @ccall libtg.tg_parse(data::Ptr{Cvoid}, len::Csize_t)::Ptr{tg_geom}
end

function tg_parse_ix(data, len, ix)
    @ccall libtg.tg_parse_ix(data::Ptr{Cvoid}, len::Csize_t, ix::tg_index)::Ptr{tg_geom}
end

function tg_geom_error(geom)
    @ccall libtg.tg_geom_error(geom::Ptr{tg_geom})::Cstring
end

function tg_geobin_fullrect(geobin, len, min, max)
    @ccall libtg.tg_geobin_fullrect(geobin::Ptr{UInt8}, len::Csize_t, min::Ptr{Cdouble}, max::Ptr{Cdouble})::Cint
end

function tg_geobin_rect(geobin, len)
    @ccall libtg.tg_geobin_rect(geobin::Ptr{UInt8}, len::Csize_t)::tg_rect
end

function tg_geobin_point(geobin, len)
    @ccall libtg.tg_geobin_point(geobin::Ptr{UInt8}, len::Csize_t)::tg_point
end

"""
    tg_geom_geojson(geom, dst, n)

` GeometryWriting Geometry writing`

Functions for writing geometries as external data representations. @{
"""
function tg_geom_geojson(geom, dst, n)
    @ccall libtg.tg_geom_geojson(geom::Ptr{tg_geom}, dst::Cstring, n::Csize_t)::Csize_t
end

function tg_geom_wkt(geom, dst, n)
    @ccall libtg.tg_geom_wkt(geom::Ptr{tg_geom}, dst::Cstring, n::Csize_t)::Csize_t
end

function tg_geom_wkb(geom, dst, n)
    @ccall libtg.tg_geom_wkb(geom::Ptr{tg_geom}, dst::Ptr{UInt8}, n::Csize_t)::Csize_t
end

function tg_geom_hex(geom, dst, n)
    @ccall libtg.tg_geom_hex(geom::Ptr{tg_geom}, dst::Cstring, n::Csize_t)::Csize_t
end

function tg_geom_geobin(geom, dst, n)
    @ccall libtg.tg_geom_geobin(geom::Ptr{tg_geom}, dst::Ptr{UInt8}, n::Csize_t)::Csize_t
end

"""
    tg_geom_new_point_z(point, z)

` GeometryConstructorsEx Geometry with alternative dimensions`

Functions for working with geometries that have more than two dimensions or are empty. The extra dimensional coordinates contained within these geometries are only carried along and serve no other purpose than to be available for when it's desired to export to an output representation such as GeoJSON, WKT, or WKB. @{
"""
function tg_geom_new_point_z(point, z)
    @ccall libtg.tg_geom_new_point_z(point::tg_point, z::Cdouble)::Ptr{tg_geom}
end

function tg_geom_new_point_m(point, m)
    @ccall libtg.tg_geom_new_point_m(point::tg_point, m::Cdouble)::Ptr{tg_geom}
end

function tg_geom_new_point_zm(point, z, m)
    @ccall libtg.tg_geom_new_point_zm(point::tg_point, z::Cdouble, m::Cdouble)::Ptr{tg_geom}
end

function tg_geom_new_point_empty()
    @ccall libtg.tg_geom_new_point_empty()::Ptr{tg_geom}
end

function tg_geom_new_linestring_z(line, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_linestring_z(line::Ptr{tg_line}, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_linestring_m(line, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_linestring_m(line::Ptr{tg_line}, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_linestring_zm(line, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_linestring_zm(line::Ptr{tg_line}, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_linestring_empty()
    @ccall libtg.tg_geom_new_linestring_empty()::Ptr{tg_geom}
end

function tg_geom_new_polygon_z(poly, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_polygon_z(poly::Ptr{tg_poly}, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_polygon_m(poly, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_polygon_m(poly::Ptr{tg_poly}, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_polygon_zm(poly, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_polygon_zm(poly::Ptr{tg_poly}, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_polygon_empty()
    @ccall libtg.tg_geom_new_polygon_empty()::Ptr{tg_geom}
end

function tg_geom_new_multipoint_z(points, npoints, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_multipoint_z(points::Ptr{tg_point}, npoints::Cint, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multipoint_m(points, npoints, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_multipoint_m(points::Ptr{tg_point}, npoints::Cint, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multipoint_zm(points, npoints, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_multipoint_zm(points::Ptr{tg_point}, npoints::Cint, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multipoint_empty()
    @ccall libtg.tg_geom_new_multipoint_empty()::Ptr{tg_geom}
end

function tg_geom_new_multilinestring_z(lines, nlines, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_multilinestring_z(lines::Ptr{Ptr{tg_line}}, nlines::Cint, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multilinestring_m(lines, nlines, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_multilinestring_m(lines::Ptr{Ptr{tg_line}}, nlines::Cint, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multilinestring_zm(lines, nlines, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_multilinestring_zm(lines::Ptr{Ptr{tg_line}}, nlines::Cint, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multilinestring_empty()
    @ccall libtg.tg_geom_new_multilinestring_empty()::Ptr{tg_geom}
end

function tg_geom_new_multipolygon_z(polys, npolys, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_multipolygon_z(polys::Ptr{Ptr{tg_poly}}, npolys::Cint, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multipolygon_m(polys, npolys, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_multipolygon_m(polys::Ptr{Ptr{tg_poly}}, npolys::Cint, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multipolygon_zm(polys, npolys, extra_coords, ncoords)
    @ccall libtg.tg_geom_new_multipolygon_zm(polys::Ptr{Ptr{tg_poly}}, npolys::Cint, extra_coords::Ptr{Cdouble}, ncoords::Cint)::Ptr{tg_geom}
end

function tg_geom_new_multipolygon_empty()
    @ccall libtg.tg_geom_new_multipolygon_empty()::Ptr{tg_geom}
end

function tg_geom_new_geometrycollection_empty()
    @ccall libtg.tg_geom_new_geometrycollection_empty()::Ptr{tg_geom}
end

"""
    tg_point_rect(point)

` PointFuncs Point functions`

Functions for working directly with the [`tg_point`](@ref) type. @{
"""
function tg_point_rect(point)
    @ccall libtg.tg_point_rect(point::tg_point)::tg_rect
end

function tg_point_intersects_rect(a, b)
    @ccall libtg.tg_point_intersects_rect(a::tg_point, b::tg_rect)::Bool
end

"""
    tg_segment_rect(s)

` SegmentFuncs Segment functions`

Functions for working directly with the [`tg_segment`](@ref) type. @{
"""
function tg_segment_rect(s)
    @ccall libtg.tg_segment_rect(s::tg_segment)::tg_rect
end

function tg_segment_intersects_segment(a, b)
    @ccall libtg.tg_segment_intersects_segment(a::tg_segment, b::tg_segment)::Bool
end

"""
    tg_rect_expand(rect, other)

` RectFuncs Rectangle functions`

Functions for working directly with the [`tg_rect`](@ref) type. @{
"""
function tg_rect_expand(rect, other)
    @ccall libtg.tg_rect_expand(rect::tg_rect, other::tg_rect)::tg_rect
end

function tg_rect_expand_point(rect, point)
    @ccall libtg.tg_rect_expand_point(rect::tg_rect, point::tg_point)::tg_rect
end

function tg_rect_center(rect)
    @ccall libtg.tg_rect_center(rect::tg_rect)::tg_point
end

function tg_rect_intersects_rect(a, b)
    @ccall libtg.tg_rect_intersects_rect(a::tg_rect, b::tg_rect)::Bool
end

function tg_rect_intersects_point(a, b)
    @ccall libtg.tg_rect_intersects_point(a::tg_rect, b::tg_point)::Bool
end

"""
    tg_ring_new(points, npoints)

` RingFuncs Ring functions`

Functions for working directly with the [`tg_ring`](@ref) type.

There are no direct spatial predicates for [`tg_ring`](@ref). If you want to perform operations like "intersects" or "covers" then you  must upcast the ring to a [`tg_geom`](@ref), like such:

``` [`tg_geom_intersects`](@ref)((struct [`tg_geom`](@ref)*)ring, geom); ``` @{
"""
function tg_ring_new(points, npoints)
    @ccall libtg.tg_ring_new(points::Ptr{tg_point}, npoints::Cint)::Ptr{tg_ring}
end

function tg_ring_new_ix(points, npoints, ix)
    @ccall libtg.tg_ring_new_ix(points::Ptr{tg_point}, npoints::Cint, ix::tg_index)::Ptr{tg_ring}
end

function tg_ring_free(ring)
    @ccall libtg.tg_ring_free(ring::Ptr{tg_ring})::Cvoid
end

function tg_ring_clone(ring)
    @ccall libtg.tg_ring_clone(ring::Ptr{tg_ring})::Ptr{tg_ring}
end

function tg_ring_copy(ring)
    @ccall libtg.tg_ring_copy(ring::Ptr{tg_ring})::Ptr{tg_ring}
end

function tg_ring_memsize(ring)
    @ccall libtg.tg_ring_memsize(ring::Ptr{tg_ring})::Csize_t
end

function tg_ring_rect(ring)
    @ccall libtg.tg_ring_rect(ring::Ptr{tg_ring})::tg_rect
end

function tg_ring_num_points(ring)
    @ccall libtg.tg_ring_num_points(ring::Ptr{tg_ring})::Cint
end

function tg_ring_point_at(ring, index)
    @ccall libtg.tg_ring_point_at(ring::Ptr{tg_ring}, index::Cint)::tg_point
end

function tg_ring_points(ring)
    @ccall libtg.tg_ring_points(ring::Ptr{tg_ring})::Ptr{tg_point}
end

function tg_ring_num_segments(ring)
    @ccall libtg.tg_ring_num_segments(ring::Ptr{tg_ring})::Cint
end

function tg_ring_segment_at(ring, index)
    @ccall libtg.tg_ring_segment_at(ring::Ptr{tg_ring}, index::Cint)::tg_segment
end

function tg_ring_convex(ring)
    @ccall libtg.tg_ring_convex(ring::Ptr{tg_ring})::Bool
end

function tg_ring_clockwise(ring)
    @ccall libtg.tg_ring_clockwise(ring::Ptr{tg_ring})::Bool
end

function tg_ring_index_spread(ring)
    @ccall libtg.tg_ring_index_spread(ring::Ptr{tg_ring})::Cint
end

function tg_ring_index_num_levels(ring)
    @ccall libtg.tg_ring_index_num_levels(ring::Ptr{tg_ring})::Cint
end

function tg_ring_index_level_num_rects(ring, levelidx)
    @ccall libtg.tg_ring_index_level_num_rects(ring::Ptr{tg_ring}, levelidx::Cint)::Cint
end

function tg_ring_index_level_rect(ring, levelidx, rectidx)
    @ccall libtg.tg_ring_index_level_rect(ring::Ptr{tg_ring}, levelidx::Cint, rectidx::Cint)::tg_rect
end

function tg_ring_nearest_segment(ring, rect_dist, seg_dist, iter, udata)
    @ccall libtg.tg_ring_nearest_segment(ring::Ptr{tg_ring}, rect_dist::Ptr{Cvoid}, seg_dist::Ptr{Cvoid}, iter::Ptr{Cvoid}, udata::Ptr{Cvoid})::Bool
end

function tg_ring_line_search(a, b, iter, udata)
    @ccall libtg.tg_ring_line_search(a::Ptr{tg_ring}, b::Ptr{tg_line}, iter::Ptr{Cvoid}, udata::Ptr{Cvoid})::Cvoid
end

function tg_ring_ring_search(a, b, iter, udata)
    @ccall libtg.tg_ring_ring_search(a::Ptr{tg_ring}, b::Ptr{tg_ring}, iter::Ptr{Cvoid}, udata::Ptr{Cvoid})::Cvoid
end

function tg_ring_area(ring)
    @ccall libtg.tg_ring_area(ring::Ptr{tg_ring})::Cdouble
end

function tg_ring_perimeter(ring)
    @ccall libtg.tg_ring_perimeter(ring::Ptr{tg_ring})::Cdouble
end

"""
    tg_line_new(points, npoints)

` LineFuncs Line functions`

Functions for working directly with the [`tg_line`](@ref) type.

There are no direct spatial predicates for [`tg_line`](@ref). If you want to perform operations like "intersects" or "covers" then you  must upcast the line to a [`tg_geom`](@ref), like such:

``` [`tg_geom_intersects`](@ref)((struct [`tg_geom`](@ref)*)line, geom); ``` @{
"""
function tg_line_new(points, npoints)
    @ccall libtg.tg_line_new(points::Ptr{tg_point}, npoints::Cint)::Ptr{tg_line}
end

function tg_line_new_ix(points, npoints, ix)
    @ccall libtg.tg_line_new_ix(points::Ptr{tg_point}, npoints::Cint, ix::tg_index)::Ptr{tg_line}
end

function tg_line_free(line)
    @ccall libtg.tg_line_free(line::Ptr{tg_line})::Cvoid
end

function tg_line_clone(line)
    @ccall libtg.tg_line_clone(line::Ptr{tg_line})::Ptr{tg_line}
end

function tg_line_copy(line)
    @ccall libtg.tg_line_copy(line::Ptr{tg_line})::Ptr{tg_line}
end

function tg_line_memsize(line)
    @ccall libtg.tg_line_memsize(line::Ptr{tg_line})::Csize_t
end

function tg_line_rect(line)
    @ccall libtg.tg_line_rect(line::Ptr{tg_line})::tg_rect
end

function tg_line_num_points(line)
    @ccall libtg.tg_line_num_points(line::Ptr{tg_line})::Cint
end

function tg_line_points(line)
    @ccall libtg.tg_line_points(line::Ptr{tg_line})::Ptr{tg_point}
end

function tg_line_point_at(line, index)
    @ccall libtg.tg_line_point_at(line::Ptr{tg_line}, index::Cint)::tg_point
end

function tg_line_num_segments(line)
    @ccall libtg.tg_line_num_segments(line::Ptr{tg_line})::Cint
end

function tg_line_segment_at(line, index)
    @ccall libtg.tg_line_segment_at(line::Ptr{tg_line}, index::Cint)::tg_segment
end

function tg_line_clockwise(line)
    @ccall libtg.tg_line_clockwise(line::Ptr{tg_line})::Bool
end

function tg_line_index_spread(line)
    @ccall libtg.tg_line_index_spread(line::Ptr{tg_line})::Cint
end

function tg_line_index_num_levels(line)
    @ccall libtg.tg_line_index_num_levels(line::Ptr{tg_line})::Cint
end

function tg_line_index_level_num_rects(line, levelidx)
    @ccall libtg.tg_line_index_level_num_rects(line::Ptr{tg_line}, levelidx::Cint)::Cint
end

function tg_line_index_level_rect(line, levelidx, rectidx)
    @ccall libtg.tg_line_index_level_rect(line::Ptr{tg_line}, levelidx::Cint, rectidx::Cint)::tg_rect
end

function tg_line_nearest_segment(line, rect_dist, seg_dist, iter, udata)
    @ccall libtg.tg_line_nearest_segment(line::Ptr{tg_line}, rect_dist::Ptr{Cvoid}, seg_dist::Ptr{Cvoid}, iter::Ptr{Cvoid}, udata::Ptr{Cvoid})::Bool
end

function tg_line_line_search(a, b, iter, udata)
    @ccall libtg.tg_line_line_search(a::Ptr{tg_line}, b::Ptr{tg_line}, iter::Ptr{Cvoid}, udata::Ptr{Cvoid})::Cvoid
end

function tg_line_length(line)
    @ccall libtg.tg_line_length(line::Ptr{tg_line})::Cdouble
end

"""
    tg_poly_new(exterior, holes, nholes)

` PolyFuncs Polygon functions`

Functions for working directly with the [`tg_poly`](@ref) type.

There are no direct spatial predicates for [`tg_poly`](@ref). If you want to perform operations like "intersects" or "covers" then you  must upcast the poly to a [`tg_geom`](@ref), like such:

``` [`tg_geom_intersects`](@ref)((struct [`tg_geom`](@ref)*)poly, geom); ``` @{
"""
function tg_poly_new(exterior, holes, nholes)
    @ccall libtg.tg_poly_new(exterior::Ptr{tg_ring}, holes::Ptr{Ptr{tg_ring}}, nholes::Cint)::Ptr{tg_poly}
end

function tg_poly_free(poly)
    @ccall libtg.tg_poly_free(poly::Ptr{tg_poly})::Cvoid
end

function tg_poly_clone(poly)
    @ccall libtg.tg_poly_clone(poly::Ptr{tg_poly})::Ptr{tg_poly}
end

function tg_poly_copy(poly)
    @ccall libtg.tg_poly_copy(poly::Ptr{tg_poly})::Ptr{tg_poly}
end

function tg_poly_memsize(poly)
    @ccall libtg.tg_poly_memsize(poly::Ptr{tg_poly})::Csize_t
end

function tg_poly_exterior(poly)
    @ccall libtg.tg_poly_exterior(poly::Ptr{tg_poly})::Ptr{tg_ring}
end

function tg_poly_num_holes(poly)
    @ccall libtg.tg_poly_num_holes(poly::Ptr{tg_poly})::Cint
end

function tg_poly_hole_at(poly, index)
    @ccall libtg.tg_poly_hole_at(poly::Ptr{tg_poly}, index::Cint)::Ptr{tg_ring}
end

function tg_poly_rect(poly)
    @ccall libtg.tg_poly_rect(poly::Ptr{tg_poly})::tg_rect
end

function tg_poly_clockwise(poly)
    @ccall libtg.tg_poly_clockwise(poly::Ptr{tg_poly})::Bool
end

"""
    tg_env_set_allocator(malloc, realloc, free)

` GlobalFuncs Global environment`

Functions for optionally setting the behavior of the TG environment. These, if desired, should be called only once at program start up and prior to calling any other tg\\_*() functions. @{
"""
function tg_env_set_allocator(malloc, realloc, free)
    @ccall libtg.tg_env_set_allocator(malloc::Ptr{Cvoid}, realloc::Ptr{Cvoid}, free::Ptr{Cvoid})::Cvoid
end

function tg_env_set_index(ix)
    @ccall libtg.tg_env_set_index(ix::tg_index)::Cvoid
end

function tg_env_set_index_spread(spread)
    @ccall libtg.tg_env_set_index_spread(spread::Cint)::Cvoid
end

function tg_env_set_print_fixed_floats(print)
    @ccall libtg.tg_env_set_print_fixed_floats(print::Bool)::Cvoid
end

