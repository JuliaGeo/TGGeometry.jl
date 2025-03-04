```@meta
CurrentModule = TGGeometry
```

# TGGeometry

TGGeometry.jl is a Julia wrapper around the [`tg`](https://github.com/tidwall/tg) C library for planar geometric predicates.  Specifically, it provides:

- [`intersects(geom1, geom2)`](@ref intersects)
- [`contains(geom1, geom2)`](@ref contains)
- [`touches(geom1, geom2)`](@ref touches)
- [`disjoint(geom1, geom2)`](@ref disjoint)
- [`equals(geom1, geom2)`](@ref equals)
- [`covers(geom1, geom2)`](@ref covers)
- [`coveredby(geom1, geom2)`](@ref coveredby)
- [`within(geom1, geom2)`](@ref within)

from the [DE-9IM](https://en.wikipedia.org/wiki/DE-9IM) model.

It is fully [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl) compatible, and is able to accept any combination of GeoInterface-compatible geometries as input (from GeoDataFrames, GeoJSON, ArchGDAL, GeometryOps, and many more packages!).

```@index
```

## Quick start

### Installation

Install via `]add TGGeometry` in the REPL, or `Pkg.add("TGGeometry")`.

### Basic usage

Since TGGeometry allows any GeoInterface-compatible geometry as input, let's start with some geometries from NaturalEarth.jl:
```@example quickstart
using NaturalEarth
using TGGeometry
all_countries = naturalearth("admin_0_countries", 10)
germany = all_countries.geometry[findfirst(==("Germany"), all_countries.NAME)]
belgium = all_countries.geometry[findfirst(==("Belgium"), all_countries.NAME)]
using CairoMakie, GeoInterfaceMakie # hide
CairoMakie.activate!(; type = :svg) # hide
f, a, p = poly(germany; label = "Germany", color = Makie.wong_colors()[1], axis = (; aspect = DataAspect(),), figure = (; size = (450, 300))) # hide
poly!(a, belgium; label = "Belgium", color = Makie.wong_colors()[2]) # hide
leg = axislegend(a; position = :lt) # hide
hidedecorations!(a) # hide
f # hide
```

```@example quickstart
TGGeometry.intersects(germany, belgium)
```

```@example quickstart
TGGeometry.contains(germany, belgium)
```

```@example quickstart
TGGeometry.touches(germany, belgium)
```

```@example quickstart
TGGeometry.disjoint(germany, belgium)
```

You can use any data loader, like GeoJSON, GeoDataFrames, ArchGDAL, etc.  You can also construct your own geometries via GeometryBasics, GeoInterface wrapper geometries, or accepted basic types like 2-tuple points.

```@example quickstart
berlin = (13.4050, 52.5200) # berlin (longitude, latitude)
scatter!(a, [berlin], color = :red, label = "Berlin") # hide
delete!(leg) # hide
leg = axislegend(a; position = :lt) # hide
f # hide`
```

```@example quickstart
TGGeometry.contains(germany, berlin)
```

### "Preparing" using `TGGeom`

TGGeometry is fast naturally, but you can make it even faster by "preparing" your geometries by converting them to `TGGeom`s.  This converts the geometries to opaque pointers to a `tg` geometry - still fully GeoInterface-compatible though, but they have the acceleration benefits and don't have to be continually converted every time you call a predicate.

The way to convert is to call `GeoInterface.convert(TGGeometry, geom)`.  This will convert the geometry to a `TGGeom` and return the new `TGGeom` object.

Let's see the difference in speed, between using a `TGGeom` and a GeoJSON polygon:

```@example quickstart
using Chairmarks, GeoInterface
gj_bench = @be TGGeometry.contains($germany, $berlin) seconds=1
```

```@example quickstart
# Convert to TGGeom
germany_tg = GeoInterface.convert(TGGeometry, germany)

tg_bench = @be TGGeometry.contains($germany_tg, $berlin) seconds=1
```

```@example quickstart
faster_factor = Statistics.median(gj_bench).time / Statistics.median(tg_bench).time 
@info "The prepared approach is about $(round(faster_factor, digits=2))x faster!"
```

## Predicates

Predicates from the DE-9IM model are available (but not a full `relate` function that would return the full DE-9IM matrix).

```@docs
intersects
contains
touches
disjoint
equals
covers
coveredby
within
```

## TGGeom

The `TGGeom` type is a wrapper around the `tg_geom` object returned by the `tg` library.  It is fully [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl) compatible, and is able to accept any combination of GeoInterface-compatible geometries as input (from GeoDataFrames, GeoJSON, ArchGDAL, GeometryOps, and many more packages!).

```@docs
TGGeom
```

## Installation

It's as simple as `]add TGGeometry`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

