/**
 * Thin reference-system integration for semantic image candidates.
 *
 * Dunia vision owns the meaning of a candidate. georef-d owns the generic
 * coordinate-space and transformation contracts. This module only defines
 * Dunia's image-pixel space and connects ImageBounds to a consumer-provided
 * affine transform.
 */
module dunia.vision.reference;

import dunia.vision.candidates : CandidateKind, ImageBounds, ObjectCandidate,
    SemanticCandidate;
import georef : AffineTransform, Coordinate, CoordinateBounds, SpaceDescriptor;

/// The pixel coordinate space used by Dunia image candidates.
alias ImagePixelSpace = SpaceDescriptor!("dunia-image-pixels", 2);

/// A coordinate in image pixel space, ordered as x then y.
alias ImageCoordinate = Coordinate!(ImagePixelSpace, double);

/// Converts an integer image position to a typed pixel coordinate.
ImageCoordinate imageCoordinate(size_t x, size_t y) @safe pure nothrow
{
    return ImageCoordinate([cast(double) x, cast(double) y]);
}

/// Transforms the inclusive candidate bounds into a consumer-defined space.
CoordinateBounds!(TargetSpace, T, 2) referencedBounds(TargetSpace, T)(
    SemanticCandidate candidate,
    AffineTransform!(ImagePixelSpace, TargetSpace, T, 2) transform)
{
    auto lower = transform.forward(ImageCoordinate([
        cast(T) candidate.object.bounds.minX,
        cast(T) candidate.object.bounds.minY]));
    auto upper = transform.forward(ImageCoordinate([
        cast(T) candidate.object.bounds.maxX,
        cast(T) candidate.object.bounds.maxY]));
    return CoordinateBounds!(TargetSpace, T, 2)(lower.values, upper.values);
}

@safe unittest
{
    struct LocalSpace { enum id = "local"; enum dimension = 2; }
    auto candidate = SemanticCandidate(CandidateKind.building,
        ObjectCandidate(ImageBounds(1, 2, 3, 4), 0.9f, 9));
    auto transform = AffineTransform!(ImagePixelSpace, LocalSpace, double, 2)(
        [[2.0, 0.0], [0.0, 2.0]], [10.0, 20.0]);
    auto bounds = referencedBounds(candidate, transform);
    assert(bounds.minimum == [12.0, 24.0]);
    assert(bounds.maximum == [16.0, 28.0]);
}
