# TGGeometry

TGGeometry.jl is a Julia wrapper around the [`tg`](https://github.com/tidwall/tg) C library for planar geometric predicates.  Specifically, it provides:

- `intersects(geom1, geom2)`
- `contains(geom1, geom2)`
- `touches(geom1, geom2)`
- `disjoint(geom1, geom2)`
- `equals(geom1, geom2)`
- `covers(geom1, geom2)`
- `coveredby(geom1, geom2)`
- `within(geom1, geom2)`

from the [DE-9IM](https://en.wikipedia.org/wiki/DE-9IM) model.

> [!TIP]
> `TGGeometry.jl` is also integrated with [GeometryOps.jl](https://github.com/JuliaGeometry/GeometryOps.jl) - 
> you can use TGGeometry predicates by first importing TGGeometry itself 
> (`import TGGeometry`) and then using GeometryOps' `GO.TG()` algorithm 
> in predicates.
> 
> `GO.intersects(GO.TG(), geom1, geom2)` is equivalent to `TGGeometry.intersects(geom1, geom2)`.

It is fully [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl) compatible, and is able to accept any combination of GeoInterface-compatible geometries as input (from GeoDataFrames, GeoJSON, ArchGDAL, GeometryOps, and many more packages!).

It also provides a GeoInterface.jl-compatible type, `TGGeom`, which can be used to wrap the C-level `tg_geom` objects returned by the `tg` library - in case you want complete speed.  You can convert any GeoInterface-compatible geometry to a `TGGeom` using `GeoInterface.convert(TGGeom, geom)`, or `GeoInterface.convert(TGGeometry, geom)`.  Similarly, you can convert a `TGGeom` back to any GeoInterface-compatible geometry using the same function.


