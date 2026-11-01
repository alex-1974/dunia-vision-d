import dunia.vision;

void main() {
    auto mask = SemanticMask(1, 1, [1.0f]);
    assert(mask.isValid);
}

