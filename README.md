# dunia-vision-d

Semantic image-interpretation building blocks for [Dunia](https://github.com/alex-1974/dunia).

This library is deliberately separate from the generic
[imagery-d](https://github.com/alex-1974/imagery-d) image-processing library.
`imagery-d` provides reusable pixels, masks, filters and segmentation
primitives; `dunia-vision-d` turns those primitives into Dunia-specific
candidate objects and semantic interpretations.

## Initial scope

The first slice defines stable data contracts for semantic masks and object
candidates. Detection algorithms are added behind these contracts as their
quality can be measured against Dunia fixtures.

Planned capabilities include road candidates, building candidates, land-cover
regions, contour tracing and confidence-aware proposals. Georeferencing,
STAC metadata and persistence remain Dunia application concerns. The optional
`dunia.vision.reference` module now provides the small application-owned
bridge from `ImageBounds` to a consumer-defined georef-d space; it does not
introduce CRS or projection semantics.

```d
import dunia.vision;

struct LocalSpace { enum id = "local"; enum dimension = 2; }

auto transform = AffineTransform!(ImagePixelSpace, LocalSpace, double, 2)(
    [[2.0, 0.0], [0.0, 2.0]], [10.0, 20.0]);
auto bounds = referencedBounds(candidate, transform);
```

## Development

```sh
dub test
```

## Status

Early development. The API is intentionally pre-1.0 and may evolve with
Dunia's consumer requirements.

> Assisted by AI; all public APIs, semantic behavior and release decisions are
> reviewed and verified by the maintainers.

