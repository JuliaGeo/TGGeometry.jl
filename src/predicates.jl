# This simply eval's all the predicate functions 
# and creates Julia / GeoInterface compatible wrappers 
# for them.

const TG_PREDICATES = (
    :equals, :intersects, :disjoint, 
    :contains, :within, :covers, 
    :coveredby, :touches
)

for jl_funcname in TG_PREDICATES
    tg_funcname = Symbol("tg_geom_$(jl_funcname)")
    # This function is solely for dispatch purposes.
    @eval function $jl_funcname(geom1, geom2)
        $jl_funcname(GI.trait(geom1), geom1, GI.trait(geom2), geom2)
    end
    # This is where the real fun happens.
    @eval function $jl_funcname(::GI.AbstractGeometryTrait, geom1, ::GI.AbstractGeometryTrait, geom2)
        tg1 = GI.convert(TGGeom, geom1) # this automatically is a no-op if geom1 is a TGGeom
        tg2 = GI.convert(TGGeom, geom2) # this automatically is a no-op if geom2 is a TGGeom
        return $(tg_funcname)(tg1.ptr, tg2.ptr)
    end    
    
end


# For PointTraits, we can save an allocation by not converting the point to TGGeom
function intersects(::GI.AbstractGeometryTrait, geom1, ::GI.PointTrait, geom2)
    tg1 = GI.convert(TGGeom, geom1) # this automatically is a no-op if geom1 is a TGGeom
    return tg_geom_intersects_xy(tg1.ptr, GI.x(geom2), GI.y(geom2))
end

# Similarly for Extents, we can use tg_rect directly, 
# instead of converting to TGGeom.
function intersects(geom1, geom2::GI.Extents.Extent)
    tg1 = GI.convert(TGGeom, geom1) # this automatically is a no-op if geom1 is a TGGeom
    rect = convert(tg_rect, geom2) # Base convert
    return tg_geom_intersects_rect(tg1.ptr, rect)
end
intersects(geom1::GI.Extents.Extent, geom2) = intersects(geom2, geom1)

function intersects(geom1::GI.Extents.Extent, geom2::GI.Extents.Extent)
    rect1 = convert(tg_rect, geom1)
    rect2 = convert(tg_rect, geom2)
    return tg_rect_intersects_rect(rect1, rect2)
end

# Finally, there is an optimized combination for points and extents, which does not require C at all.
# Although we have this same thing in Extents.jl - this is more for completeness.
function intersects(trait, geom1::GI.Extents.Extent, ::GI.PointTrait, geom2)
    rect = convert(tg_rect, geom1)
    point = tg_point(GI.x(geom2), GI.y(geom2))
    return tg_rect_intersects_xy(rect, point)
end


# Now we actually have to add docs to each function

const DE9IM_INLINE = "[^de9im]"
const DE9IM_FOOTNOTE = "[^de9im]: the [Dimensionally Extended 9-Intersection Model](https://en.wikipedia.org/wiki/DE-9IM) that describes the relationship between two planar geometries."
const ARGS_DOC = """
# Arguments
- `geom1`: The first geometry.  May be any GeoInterface-compatible geometry.
- `geom2`: The second geometry.  May be any GeoInterface-compatible geometry.
"""

@doc """
    intersects(geom1, geom2)

Check if `geom1` and `geom2` intersect, as defined by DE-9IM $DE9IM_INLINE.

Specifically, this checks that the intersection of two geometries does not result in an empty set.

$ARGS_DOC

$DE9IM_FOOTNOTE
"""
intersects

@doc """
    equals(geom1, geom2)

Check if `geom1` and `geom2` are spatially equal, as defined by DE-9IM $DE9IM_INLINE.

$ARGS_DOC

$DE9IM_FOOTNOTE 
"""
equals

@doc """
    disjoint(geom1, geom2)

Check if `geom1` and `geom2` are disjoint (completely non-intersecting and separate), as defined by DE-9IM $DE9IM_INLINE.

$ARGS_DOC

$DE9IM_FOOTNOTE
"""
disjoint

@doc """
    contains(geom1, geom2)

Check if `geom1` completely contains `geom2`, as defined by DE-9IM $DE9IM_INLINE.

This means that the boundary and interior of `geom2` lie entirely inside `geom1`, and they cannot intersect the exterior of `geom1`.

$ARGS_DOC

$DE9IM_FOOTNOTE
"""
contains

@doc """
    covers(geom1, geom2)

Check if `geom1` covers `geom2`, as defined by DE-9IM $DE9IM_INLINE.

This means that no points of `geom2` lie outside of `geom1`.

$ARGS_DOC

$DE9IM_FOOTNOTE
"""
covers

@doc """
    coveredby(geom1, geom2)

Check if `geom1` is covered by `geom2`, as defined by DE-9IM $DE9IM_INLINE.

This means that no points of `geom1` lie outside of `geom2`.  

Equivalent to `covers(geom2, geom1)` - argument order reversed.

$ARGS_DOC

$DE9IM_FOOTNOTE
"""
coveredby

@doc """
    touches(geom1, geom2)

Check if `geom1` touches `geom2`, as defined by DE-9IM $DE9IM_INLINE.

This means that the intersection of two geometries has at least one point in common, but does not completely contain the other.

$ARGS_DOC

$DE9IM_FOOTNOTE
"""
touches

@doc """
    within(geom1, geom2)

Check if `geom1` is within `geom2`, as defined by DE-9IM $DE9IM_INLINE.

This means that the boundary and interior of `geom1` lie entirely inside `geom2`, and they cannot intersect the exterior of `geom2`.

This is the opposite of `contains(geom2, geom1)`.

$ARGS_DOC

$DE9IM_FOOTNOTE
"""
within