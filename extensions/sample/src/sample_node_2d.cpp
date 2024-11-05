#include "sample_node_2d.h"

using namespace godot;
using namespace sample;

void SampleNode2D::_bind_methods() {
}

void SampleNode2D::_process(double delta) {
    _angle += delta * Math_PI / 2.0;
    set_position(Vector2(
        Math::sin((real_t)_angle) * 128.0,
        Math::cos((real_t)_angle) * 128.0
    ));
}

SampleNode2D::SampleNode2D() {
    _angle = 0.0;
}

SampleNode2D::~SampleNode2D() {
}
