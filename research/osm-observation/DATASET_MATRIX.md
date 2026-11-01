# Observation dataset matrix

The vision research must use a stratified dataset. A single well-behaved
region would hide projection, illumination, surface and mapping-quality
failures.

## Geographic strata

At minimum, select scenes from:

- polar and sub-polar regions;
- temperate mid-latitudes;
- tropical regions;
- equatorial regions;
- coastal and inland areas;
- mountainous, hilly and flat terrain.

The pole/equator distinction is important for map projection behaviour,
illumination, shadows, seasonal effects and available imagery geometry. The
analysis must retain the source CRS and the chosen working/reference space;
images must not be compared only by their displayed pixel dimensions.

## Settlement and land-cover strata

Each geographic group should contain:

- dense urban fabric;
- suburban/peri-urban fabric;
- villages and small settlements;
- rural agricultural land;
- open grassland;
- forest edge and forest interior;
- arid or sparsely vegetated ground;
- wetlands and coastal margins.

## Road and path strata

Road samples should distinguish at least:

- paved primary or secondary road;
- paved local road;
- unpaved road on bare ground;
- unpaved way on grassland;
- track through vegetation or forest;
- road under partial tree canopy;
- road near buildings;
- road at a junction or roundabout;
- bridge, tunnel entrance or other special context.

The OSM geometry should be stored together with relevant tags such as
`highway`, `surface`, `tracktype`, `smoothness`, `width` and `bridge` when
available. The detector must not assume that every `highway` way has the same
visual signature.

## Building strata

Include:

- isolated rural buildings;
- dense urban blocks;
- detached houses;
- industrial or large-roof buildings;
- buildings among trees;
- buildings in bare or agricultural surroundings;
- informal or irregular settlements;
- partially obscured or shadowed buildings.

## Image-quality strata

For each object class, retain scenes with different:

- cloud and cloud-shadow coverage;
- sun elevation and azimuth;
- seasonal vegetation state;
- haze and atmospheric contrast;
- nominal and effective resolution;
- image sharpness;
- radiometric normalization;
- acquisition date relative to OSM capture/update date;
- view angle and mosaicking behaviour.

## Required metadata

Every sample should record:

```text
sample id
region and approximate latitude band
OSM object id and tags
OSM geometry and capture/update metadata when available
imagery source and product
acquisition time
processing level
CRS and pixel size
source footprint/AOI
cloud and quality masks
sun/sensor geometry when available
license and download provenance
```

## Evaluation dimensions

Reports should separate:

- object visibility;
- pixel/spectral contrast;
- geometric alignment;
- structural continuity;
- estimated width or area;
- false-positive context;
- quality-dependent confidence;
- temporal mismatch;
- projection/transform error.

Results must be reported by stratum, not only as one aggregate score. A road
detector that works on paved urban roads but fails on unpaved rural tracks is
not generally reliable, even if its global score looks good.

