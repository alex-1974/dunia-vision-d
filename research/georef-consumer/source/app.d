import dunia.vision;
import georef;
import raster.region : Region2D;

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

CoordinateBounds!(DuniaReferenceFrame, double) transformBounds(
    AffineTransform!(DuniaImagePixels, DuniaReferenceFrame, double, 2) transform,
    ImageBounds bounds)
{
    auto a = toReference(transform, cast(double) bounds.minX,
        cast(double) bounds.minY);
    auto b = toReference(transform, cast(double) bounds.maxX,
        cast(double) bounds.maxY);
    return CoordinateBounds!(DuniaReferenceFrame, double)(
        [a.values[0] < b.values[0] ? a.values[0] : b.values[0],
         a.values[1] < b.values[1] ? a.values[1] : b.values[1]],
        [a.values[0] > b.values[0] ? a.values[0] : b.values[0],
         a.values[1] > b.values[1] ? a.values[1] : b.values[1]]);
}

ReferenceCoordinate[] transformPolygon(
    AffineTransform!(DuniaImagePixels, DuniaReferenceFrame, double, 2) transform,
    const PixelCoordinate[] polygon)
{
    ReferenceCoordinate[] result;
    result.reserve(polygon.length);
    foreach (point; polygon)
        result ~= transform.forward(point);
    return result;
}

Region2D rasterRegion(ImageBounds bounds)
{
    // dunia-vision ImageBounds uses inclusive maxima; raster-d regions use
    // an origin plus an extent, so the extent is inclusive width/height.
    assert(bounds.maxX >= bounds.minX && bounds.maxY >= bounds.minY);
    return Region2D(bounds.minX, bounds.minY,
        bounds.maxX - bounds.minX + 1,
        bounds.maxY - bounds.minY + 1);
}

CoordinateBounds!(DuniaReferenceFrame, double) activeMaskBounds(
    SemanticMask mask,
    float threshold,
    AffineTransform!(DuniaImagePixels, DuniaReferenceFrame, double, 2) transform)
{
    assert(mask.isValid);
    bool found;
    double[2] minimum;
    double[2] maximum;
    foreach (index, confidence; mask.confidence)
    {
        if (confidence < threshold)
            continue;
        auto x = index % mask.width;
        auto y = index / mask.width;
        auto world = toReference(transform, cast(double) x + 0.5,
            cast(double) y + 0.5);
        if (!found)
        {
            minimum = world.values;
            maximum = world.values;
            found = true;
        }
        else
        {
            foreach (axis; 0 .. 2)
            {
                if (world.values[axis] < minimum[axis])
                    minimum[axis] = world.values[axis];
                if (world.values[axis] > maximum[axis])
                    maximum[axis] = world.values[axis];
            }
        }
    }
    assert(found);
    return CoordinateBounds!(DuniaReferenceFrame, double)(minimum, maximum);
}

void main()
{
    auto candidate = SemanticCandidate(
        CandidateKind.building,
        ObjectCandidate(ImageBounds(10, 20, 30, 50), 0.9f, 400));
    auto sourceRegion = rasterRegion(candidate.object.bounds);
    assert(sourceRegion.x == 10 && sourceRegion.y == 20);
    assert(sourceRegion.width == 21 && sourceRegion.height == 31);

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

    auto referenceBounds = transformBounds(pixelToReference,
        candidate.object.bounds);
    assert(referenceBounds.minimum == [120.0, 400.0]);
    assert(referenceBounds.maximum == [160.0, 460.0]);

    auto imageFootprint = [
        pixel(10, 20), pixel(30, 20), pixel(30, 50), pixel(10, 50),
        pixel(10, 20)];
    auto referenceFootprint = transformPolygon(pixelToReference,
        imageFootprint);
    assert(referenceFootprint[0].values == [120.0, 460.0]);
    assert(referenceFootprint[2].values == [160.0, 400.0]);
    assert(referenceFootprint[$ - 1].values == referenceFootprint[0].values);

    auto mask = SemanticMask(2, 2, [0.1f, 0.9f, 0.2f, 0.95f]);
    auto activeBounds = activeMaskBounds(mask, 0.8f, pixelToReference);
    // Active pixel centers are (1.5, 0.5) and (1.5, 1.5).
    assert(activeBounds.minimum == [103.0, 497.0]);
    assert(activeBounds.maximum == [103.0, 499.0]);

    AffineTransform!(DuniaReferenceFrame, DuniaImagePixels, double, 2) inverse;
    assert(pixelToReference.tryInverse(inverse));
    auto roundTrip = inverse.forward(topLeft);
    assert(roundTrip.values == [10.0, 20.0]);
}

