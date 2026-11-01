# georef-d consumer feedback

This document records findings from using `georef-d` with the current
`dunia-vision-d` candidate and mask types. The experiment deliberately uses
consumer-owned spaces and does not ask `georef-d` to define Dunia, image or
OSM semantics.

## Confirmed useful API

The following is already usable and intuitive for a consumer:

- user-defined static space types with `id` and `dimension`;
- `Coordinate!(Space, T)` for space-typed values;
- `AffineTransform!(Source, Target, T, Dimension)`;
- explicit inverse construction with `tryInverse`;
- typed transformation of candidate points and polygon vertices;
- runtime spaces and graph execution for externally described data.

The static source/target types prevented accidental mixing of image and
reference coordinates without requiring any Dunia-specific dependency.

## Current consumer-side helpers

The experiment currently implements these helpers locally:

- transforming an `ImageBounds` into target-space bounds;
- transforming polygon vertices;
- mapping active `SemanticMask` pixel centers into target-space bounds.

These helpers are intentionally not yet proposed as `georef-d` API. They
combine coordinate transformation with domain-specific geometry or mask
semantics.

## Findings

### Bounds

Bounds transformation needs all relevant corners for a general transform. A
two-corner implementation is sufficient for the current affine experiment,
but is not generally correct for rotation, nonlinear transforms or transforms
whose extrema occur between corners.

`georef-d` should therefore avoid assuming that a generic `CoordinateBounds`
can always be transformed by transforming only its minimum and maximum points.

### Polygons

Polygon vertex transformation is straightforward when the polygon is already
owned by the consumer. `georef-d` does not need to own polygon topology. A
future adapter can transform a range of typed coordinates while preserving the
consumer's geometry type and closure rules.

### Masks and rasters

A semantic mask is not just a collection of coordinates. Transforming it into
another grid requires rasterization, resampling, coverage rules and usually a
quality policy. These responsibilities belong to `raster-d`/`imagery-d` or a
consumer adapter, not to the generic `georef-d` core.

Pixel-center semantics are nevertheless important and must remain expressible
by a consumer. The experiment uses `(column + 0.5, row + 0.5)` for pixel
centers.

The experiment also performs a small nearest-neighbor remap into a different
target grid by using the inverse georef transform. This confirms that the
current transform API is sufficient for a simple remapping loop, while the
remapping policy itself remains domain-specific.

The following concerns must remain outside the georef core:

- nearest-neighbor versus bilinear or area-weighted sampling;
- source and target grid definitions;
- NoData and cloud/quality masks;
- confidence aggregation and thresholding;
- categorical versus continuous values;
- edge and coverage policy.

The current `SemanticMask` has no separate NoData channel. A production
integration should not overload confidence values with NoData semantics without
an explicit contract.

### Affine inverse

The consumer experiment found and covered a regression in affine inversion:
the augmented matrix had the wrong shape, the identity block was initialized
in the wrong half, and the inverse offset accumulator was not initialized.

## Candidate future work for georef-d

These are proposals, not requirements for the generic core:

1. A batch-oriented transform contract for caller-owned coordinate buffers.
2. A clearly documented range/sequence adapter for transforming coordinates
   without taking ownership of geometry.
3. Optional transform-domain metadata for validity checks.
4. Explicit support for transformations with different source and target
   dimensions.
5. A more general transformation result model for non-invertible or
   approximate transforms.

None of these should introduce fixed Dunia, OSM, satellite or unit catalogues.

## Test boundary

The next layer should use `raster-d`/`imagery-d` to test actual grid remapping.
That experiment should consume a georef transform but keep mask coverage,
resampling and image quality policies outside `georef-d`.

