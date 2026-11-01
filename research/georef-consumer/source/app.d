import dunia.vision;
import georef;

/// Consumer-owned spaces: georef assigns them no domain meaning.
struct DuniaImagePixels
{
    enum id = "dunia-image-pixels";
    enum dimension = 2;
}

struct DuniaReferenceFrame
{
    enum id = "dunia-reference-frame";
    enum dimension = 2;
}

alias PixelCoordinate = Coordinate!(DuniaImagePixels, double);
alias ReferenceCoordinate = Coordinate!(DuniaReferenceFrame, double);

PixelCoordinate pixel(double x, double y)
{
    return PixelCoordinate([x, y]);
}

ReferenceCoordinate toReference(
    AffineTransform!(DuniaImagePixels, DuniaReferenceFrame, double, 2) transform,
    double x,
    double y)
{
    return transform.forward(pixel(x, y));
}

void main()
{
    auto candidate = SemanticCandidate(
        CandidateKind.building,
        ObjectCandidate(ImageBounds(10, 20, 30, 50), 0.9f, 400));

    auto pixelToReference = AffineTransform!(
        DuniaImagePixels, DuniaReferenceFrame, double, 2)(
        [[2.0, 0.0], [0.0, -2.0]], [100.0, 500.0]);

    auto topLeft = toReference(pixelToReference,
        cast(double) candidate.object.bounds.minX,
        cast(double) candidate.object.bounds.minY);
    auto bottomRight = toReference(pixelToReference,
        cast(double) candidate.object.bounds.maxX,
        cast(double) candidate.object.bounds.maxY);

    assert(topLeft.values == [120.0, 460.0]);
    assert(bottomRight.values == [160.0, 400.0]);

    AffineTransform!(DuniaReferenceFrame, DuniaImagePixels, double, 2) inverse;
    assert(pixelToReference.tryInverse(inverse));
    auto roundTrip = inverse.forward(topLeft);
    assert(roundTrip.values == [10.0, 20.0]);
}

