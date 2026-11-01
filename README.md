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
STAC metadata and persistence remain Dunia application concerns.

## Development

```sh
dub test
```

## Status

Early development. The API is intentionally pre-1.0 and may evolve with
Dunia's consumer requirements.

> Assisted by AI; all public APIs, semantic behavior and release decisions are
> reviewed and verified by the maintainers.

