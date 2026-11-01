import dunia.vision;
import georef;
import raster.region : Region2D;
import std.math : fabs;

struct ImageSpace
{
    enum id = "observation-image-pixels";
    enum dimension = 2;
}

struct ReferenceSpace
{
    enum id = "observation-reference";
    enum dimension = 2;
}

alias ImageCoordinate = Coordinate!(ImageSpace, double);
alias ReferenceCoordinate = Coordinate!(ReferenceSpace, double);

struct OSMFeature
{
    long id;
    string kind;
    CoordinateBounds!(ReferenceSpace, double) bounds;
}

struct ObservationReport
{
    long featureId;
    string kind;
    size_t interiorSamples;
    size_t exteriorSamples;
    double interiorMean;
    double exteriorMean;

    @property double contrast() const
    {
        return interiorMean - exteriorMean;
    }
}

double imageValue(size_t x, size_t y)
{
    // Bright rectangular feature on a darker background.
    if (x >= 4 && x < 8 && y >= 5 && y < 9)
        return 1.0;
    return 0.1;
}

ObservationReport observe(
    OSMFeature feature,
    size_t width,
    size_t height,
    AffineTransform!(ImageSpace, ReferenceSpace, double, 2) imageToReference)
{
    AffineTransform!(ReferenceSpace, ImageSpace, double, 2) referenceToImage;
    assert(imageToReference.tryInverse(referenceToImage));

    double interiorSum = 0;
    double exteriorSum = 0;
    size_t interiorCount;
    size_t exteriorCount;

    foreach (y; 0 .. height)
    {
        foreach (x; 0 .. width)
        {
            auto reference = imageToReference.forward(ImageCoordinate([
                cast(double) x + 0.5, cast(double) y + 0.5]));
            auto inside = reference.values[0] >= feature.bounds.minimum[0]
                && reference.values[0] < feature.bounds.maximum[0]
                && reference.values[1] >= feature.bounds.minimum[1]
                && reference.values[1] < feature.bounds.maximum[1];
            auto value = imageValue(x, y);
            if (inside)
            {
                interiorSum += value;
                ++interiorCount;
            }
            else if (reference.values[0] >= feature.bounds.minimum[0] - 2
                && reference.values[0] < feature.bounds.maximum[0] + 2
                && reference.values[1] >= feature.bounds.minimum[1] - 2
                && reference.values[1] < feature.bounds.maximum[1] + 2)
            {
                exteriorSum += value;
                ++exteriorCount;
            }
        }
    }

    assert(interiorCount != 0 && exteriorCount != 0);
    return ObservationReport(feature.id, feature.kind, interiorCount,
        exteriorCount, interiorSum / interiorCount, exteriorSum / exteriorCount);
}

void main()
{
    auto imageToReference = AffineTransform!(
        ImageSpace, ReferenceSpace, double, 2)(
        [[1.0, 0.0], [0.0, 1.0]], [0.0, 0.0]);
    auto feature = OSMFeature(1234, "building",
        CoordinateBounds!(ReferenceSpace, double)([4.0, 5.0], [8.0, 9.0]));
    auto sourceRegion = Region2D(4, 5, 4, 4);
    assert(sourceRegion.width == 4 && sourceRegion.height == 4);

    auto report = observe(feature, 12, 12, imageToReference);
    assert(report.featureId == 1234);
    assert(report.kind == "building");
    assert(report.interiorSamples == 16);
    assert(report.interiorMean > report.exteriorMean);
    assert(report.contrast > 0.5);
    assert(fabs(report.interiorMean - 1.0) < 0.000001);
}

