/**
 * Consumer-facing semantic candidate types.
 *
 * These types describe interpretation results without encoding a particular
 * detector. Detector implementations may use imagery-d filters, masks,
 * connected components or segmentation internally.
 */
module dunia.vision.candidates;

/// A binary or confidence-valued semantic selection over an image plane.
struct SemanticMask {
    size_t width;
    size_t height;
    const(float)[] confidence;

    bool isValid() const @safe pure nothrow {
        return width != 0 && height != 0 && confidence.length == width * height;
    }
}

/// Bounding box in image coordinates for a proposed semantic object.
struct ImageBounds {
    size_t minX;
    size_t minY;
    size_t maxX;
    size_t maxY;
}

/// A detector-independent candidate object returned to Dunia workflows.
struct ObjectCandidate {
    ImageBounds bounds;
    float confidence;
    size_t pixelCount;
}

/// Semantic category assigned by a Dunia vision detector.
enum CandidateKind {
    unknown,
    road,
    building,
    water,
    vegetation,
    bareGround
}

/// Candidate with an explicit semantic category.
struct SemanticCandidate {
    CandidateKind kind;
    ObjectCandidate object;
}

@safe unittest {
    auto mask = SemanticMask(2, 2, [1.0f, 0.0f, 0.5f, 1.0f]);
    assert(mask.isValid);
    auto candidate = SemanticCandidate(CandidateKind.building,
        ObjectCandidate(ImageBounds(0, 0, 1, 1), 0.9f, 4));
    assert(candidate.kind == CandidateKind.building);
}

