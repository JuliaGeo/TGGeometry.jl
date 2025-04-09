# TGGeometry

<p align="center">
<img src="docs/src/assets/logo.png" width="240" alt="TG logo">
</p>

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
<!--
add this back when GeometryOps releases this
> [!TIP]
> `TGGeometry.jl` is also integrated with [GeometryOps.jl](https://github.com/JuliaGeometry/GeometryOps.jl) - 
> you can use TGGeometry predicates by first importing TGGeometry itself 
> (`import TGGeometry`) and then using GeometryOps' `GO.TG()` algorithm 
> in predicates.
> 
> `GO.intersects(GO.TG(), geom1, geom2)` is equivalent to `TGGeometry.intersects(geom1, geom2)`.
-->

It is fully [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl) compatible, and is able to accept any combination of GeoInterface-compatible geometries as input (from GeoDataFrames, GeoJSON, ArchGDAL, GeometryOps, and many more packages!).

It also provides a GeoInterface.jl-compatible type, `TGGeom`, which can be used to wrap the C-level `tg_geom` objects returned by the `tg` library - in case you want complete speed.  You can convert any GeoInterface-compatible geometry to a `TGGeom` using `GeoInterface.convert(TGGeom, geom)`, or `GeoInterface.convert(TGGeometry, geom)`.  Similarly, you can convert a `TGGeom` back to any GeoInterface-compatible geometry using the same function

## Quick start

### Installation

Install via `]add TGGeometry` in the REPL, or `Pkg.add("TGGeometry")`.

### Basic usage

Since TGGeometry allows any GeoInterface-compatible geometry as input, let's start with some geometries from NaturalEarth.jl:
```julia
using NaturalEarth
all_countries = naturalearth("admin_0_countries", 10)
germany = all_countries.geometry[findfirst(==("Germany"), all_countries.NAME)]
belgium = all_countries.geometry[findfirst(==("Belgium"), all_countries.NAME)]

using TGGeometry
TGGeometry.intersects(germany, belgium) # true
TGGeometry.contains(germany, belgium) # false
TGGeometry.touches(germany, belgium) # true
TGGeometry.disjoint(germany, belgium) # false
```

You can use any data loader, like GeoJSON, GeoDataFrames, ArchGDAL, etc.  You can also construct your own geometries via GeometryBasics, GeoInterface wrapper geometries, or accepted basic types like 2-tuple points.

```julia
berlin = (13.4050, 52.5200) # berlin (latitude, longitude)

TGGeometry.contains(germany, berlin) # true
```

### "Preparing" using `TGGeom`

TGGeometry is fast naturally, but you can make it even faster by "preparing" your geometries by converting them to `TGGeom`s.  This converts the geometries to opaque pointers to a `tg` geometry - still fully GeoInterface-compatible though, but they have the acceleration benefits and don't have to be continually converted every time you call a predicate.

The way to convert is to call `GeoInterface.convert(TGGeometry, geom)`.  This will convert the geometry to a `TGGeom` and return the new `TGGeom` object.

Let's see the difference in speed, between using a `TGGeom` and a GeoJSON polygon:

```julia
using Chairmarks, GeoInterface
gj_bench = @be TGGeometry.contains($germany, $berlin)
```
```
Benchmark: 2566 samples with 1 evaluation
 min    22.333 μs (50 allocs: 49.203 KiB)
 median 28.792 μs (50 allocs: 49.203 KiB)
 mean   36.276 μs (50 allocs: 49.203 KiB, 0.40% gc time)
 max    12.164 ms (50 allocs: 49.203 KiB, 99.44% gc time)
```
```julia
# Convert to TGGeom
germany_tg = GeoInterface.convert(TGGeometry, germany)

tg_bench = @be TGGeometry.contains($germany_tg, $berlin)
```
```
Benchmark: 2355 samples with 305 evaluations
 min    32.029 ns (1 allocs: 16 bytes)
 median 42.329 ns (1 allocs: 16 bytes)
 mean   45.290 ns (1 allocs: 16 bytes, 0.04% gc time)
 max    3.553 μs (1 allocs: 16 bytes, 97.27% gc time)
```

The prepared approach is about **700x** faster!
