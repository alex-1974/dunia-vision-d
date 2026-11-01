# georef-d consumer experiment

This experiment evaluates `georef-d` against a real `dunia-vision-d` consumer
shape without adding georef-specific semantics to the production API.

It models a semantic candidate's image bounds in a user-defined pixel space,
transforms the bounds into a user-defined Dunia reference space, and verifies a
round trip back to image coordinates.

The experiment uses the sibling workspace checkout of `georef-d` and is
intentionally not part of the default package test.

Run from this directory:

```sh
dub run
```

