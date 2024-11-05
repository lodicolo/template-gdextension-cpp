#include <godot_cpp/classes/node2d.hpp>

using namespace godot;

namespace sample {

    class SampleNode2D : public Node2D {
        GDCLASS(SampleNode2D, Node2D)

    private:
        double _angle;

    protected:
        static void _bind_methods();

    public:
        SampleNode2D();
        ~SampleNode2D();

        void _process(double delta) override;
    };

}