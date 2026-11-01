# OSM observation experiment

Controlled OSM-to-image observation experiment for `dunia-vision-d`.

The experiment uses a consumer-owned reference feature, a synthetic raster and
a `georef-d` transform. It samples the feature interior and an exterior ring
and reports the mean image value and contrast. The reference feature shape is
deliberately compatible with an OSM building/area feature, while keeping OSM
file parsing outside this first experiment.

Run with:

```sh
dub run
```

