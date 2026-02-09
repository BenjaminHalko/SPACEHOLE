/// @author YellowAfterlife (Windows), Linux port
/// Linux implementation of window_shape extension

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/extensions/shape.h>
#include <X11/extensions/Xcomposite.h>
#include <X11/extensions/Xfixes.h>
#include <vector>
#include <cstring>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cmath>

using namespace std;

// Export macros
#define dllx extern "C" __attribute__((visibility("default")))
#define dllg /* tag */

// Type definitions - X11 uses XserverRegion or we can use our own path structure
struct PathPoint { int32_t x, y; };

struct window_shape_data {
    std::vector<PathPoint> points;
    int mode; // 1 = alternate (EvenOddRule), 2 = winding (WindingRule)
    bool is_rect;
    int x1, y1, x2, y2; // for simple rectangles
    bool is_ellipse;
    int cx, cy, rx, ry; // for ellipses
};

using window_shape = window_shape_data*;

template <typename T> using gml_ptr = T*;
template <typename T> using gml_ptr_destroy = T*;
template <typename T> using gml_id = T;
template <typename T> using gml_id_destroy = T;

// Tracing disabled for production
#define trace(...) do {} while(0)

#pragma region GML Buffer/Stream helpers

class gml_buffer {
private:
    uint8_t* _data;
    int32_t _size;
    int32_t _tell;
public:
    gml_buffer() : _data(nullptr), _tell(0), _size(0) {}
    gml_buffer(uint8_t* data, int32_t size, int32_t tell) : _data(data), _size(size), _tell(tell) {}

    inline uint8_t* data() { return _data; }
    inline int32_t tell() { return _tell; }
    inline int32_t size() { return _size; }
};

class gml_istream {
    uint8_t* pos;
    uint8_t* start;
public:
    gml_istream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

    template<class T> T read() {
        T result{};
        std::memcpy(&result, pos, sizeof(T));
        pos += sizeof(T);
        return result;
    }

    char* read_string() {
        char* r = (char*)pos;
        while (*pos != 0) pos++;
        pos++;
        return r;
    }

    gml_buffer read_gml_buffer() {
        auto _data = (uint8_t*)read<int64_t>();
        auto _size = read<int32_t>();
        auto _tell = read<int32_t>();
        return gml_buffer(_data, _size, _tell);
    }
};

class gml_ostream {
    uint8_t* pos;
    uint8_t* start;
public:
    gml_ostream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

    template<class T> void write(T val) {
        memcpy(pos, &val, sizeof(T));
        pos += sizeof(T);
    }
};

#pragma endregion

#pragma region Global state

static Display* display = nullptr;
static Window window = 0;

#pragma endregion

#pragma region Shape Creation

gml_id<window_shape> window_shape_create_empty() {
    auto shape = new window_shape_data();
    shape->is_rect = true;
    shape->x1 = shape->y1 = shape->x2 = shape->y2 = 0;
    shape->is_ellipse = false;
    shape->mode = 2; // winding
    return shape;
}

gml_id<window_shape> window_shape_create_rectangle(int x1, int y1, int x2, int y2) {
    auto shape = new window_shape_data();
    shape->is_rect = true;
    shape->x1 = x1;
    shape->y1 = y1;
    shape->x2 = x2;
    shape->y2 = y2;
    shape->is_ellipse = false;
    shape->mode = 2;
    return shape;
}

gml_id<window_shape> window_shape_create_round_rectangle(int x1, int y1, int x2, int y2, int w, int h) {
    // Approximate with polygon points
    auto shape = new window_shape_data();
    shape->is_rect = false;
    shape->is_ellipse = false;
    shape->mode = 2;

    int radius = (w < h ? w : h) / 2;
    int width = x2 - x1;
    int height = y2 - y1;

    // Generate rounded rectangle as polygon
    const int segments = 8;
    auto& pts = shape->points;

    // Top edge (left to right)
    pts.push_back({x1 + radius, y1});
    pts.push_back({x2 - radius, y1});

    // Top-right corner
    for (int i = 0; i <= segments; i++) {
        double angle = -M_PI/2 + (M_PI/2) * i / segments;
        pts.push_back({(int)(x2 - radius + radius * cos(angle)), (int)(y1 + radius + radius * sin(angle))});
    }

    // Right edge
    pts.push_back({x2, y1 + radius});
    pts.push_back({x2, y2 - radius});

    // Bottom-right corner
    for (int i = 0; i <= segments; i++) {
        double angle = 0 + (M_PI/2) * i / segments;
        pts.push_back({(int)(x2 - radius + radius * cos(angle)), (int)(y2 - radius + radius * sin(angle))});
    }

    // Bottom edge
    pts.push_back({x2 - radius, y2});
    pts.push_back({x1 + radius, y2});

    // Bottom-left corner
    for (int i = 0; i <= segments; i++) {
        double angle = M_PI/2 + (M_PI/2) * i / segments;
        pts.push_back({(int)(x1 + radius + radius * cos(angle)), (int)(y2 - radius + radius * sin(angle))});
    }

    // Left edge
    pts.push_back({x1, y2 - radius});
    pts.push_back({x1, y1 + radius});

    // Top-left corner
    for (int i = 0; i <= segments; i++) {
        double angle = M_PI + (M_PI/2) * i / segments;
        pts.push_back({(int)(x1 + radius + radius * cos(angle)), (int)(y1 + radius + radius * sin(angle))});
    }

    return shape;
}

gml_id<window_shape> window_shape_create_ellipse(int x1, int y1, int x2, int y2) {
    auto shape = new window_shape_data();
    shape->is_rect = false;
    shape->is_ellipse = true;
    shape->cx = (x1 + x2) / 2;
    shape->cy = (y1 + y2) / 2;
    shape->rx = (x2 - x1) / 2;
    shape->ry = (y2 - y1) / 2;
    shape->mode = 2;

    // Also generate polygon points for X11 shape extension
    const int segments = 64;
    for (int i = 0; i < segments; i++) {
        double angle = 2 * M_PI * i / segments;
        shape->points.push_back({
            (int)(shape->cx + shape->rx * cos(angle)),
            (int)(shape->cy + shape->ry * sin(angle))
        });
    }

    return shape;
}

gml_id<window_shape> window_shape_create_circle(int x, int y, int rad) {
    return window_shape_create_ellipse(x - rad, y - rad, x + rad, y + rad);
}

gml_id<window_shape> window_shape_create_polygon_from_buffer(gml_buffer b, int mode, int count = -1) {
    struct Point { int32_t x, y; };
    static_assert(sizeof(Point) == 8, "Point must be 8 bytes");

    if (count == -1) count = b.tell() / 8;
    if (count < 3) return window_shape_create_empty();

    Point* points = (Point*)b.data();
    auto shape = new window_shape_data();
    shape->is_rect = false;
    shape->is_ellipse = false;
    shape->mode = mode;

    for (int i = 0; i < count; i++) {
        shape->points.push_back({points[i].x, points[i].y});
    }

    return shape;
}

gml_id<window_shape> window_shape_create_polygon_from_path_data(gml_buffer b, int mode, bool closed, bool smooth, int precision, int count) {
    struct GmlPathPoint { double x, y; };
    static_assert(sizeof(GmlPathPoint) == 16, "GmlPathPoint must be 16 bytes");

    if (count < 2) return window_shape_create_empty();

    auto in = (GmlPathPoint*)b.data();
    auto shape = new window_shape_data();
    shape->is_rect = false;
    shape->is_ellipse = false;
    shape->mode = mode;

    if (!smooth) {
        for (int i = 0; i < count; i++) {
            shape->points.push_back({(int)in[i].x, (int)in[i].y});
        }
        return shape;
    }

    // Smooth path interpolation
    auto step = 1.0 / (double)precision;
    int last = count - 1;

    for (int i = 0; i < count; i++) {
        auto prev = &in[closed ? (i == 0 ? last : i - 1) : (i == 0 ? 0 : i - 1)];
        auto curr = &in[i];
        auto next = &in[closed ? (i == last ? 0 : i + 1) : (i == last ? last : i + 1)];

        auto pos = 0.0;
        for (int k = 0; k < precision; k++) {
            double px = 0.5 * (((prev->x - 2.0 * curr->x + next->x) * pos + 2.0 * (curr->x - prev->x)) * pos + prev->x + curr->x);
            double py = 0.5 * (((prev->y - 2.0 * curr->y + next->y) * pos + 2.0 * (curr->y - prev->y)) * pos + prev->y + curr->y);
            shape->points.push_back({(int)px, (int)py});
            pos += step;
        }
    }

    return shape;
}

gml_id<window_shape> window_shape_create_rectangles_from_rgba(gml_buffer b, int tolerance, int width, int height) {
    struct rgba { uint8_t r, g, b, a; };
    auto ptr = (rgba*)b.data();
    auto shape = new window_shape_data();
    shape->is_rect = false;
    shape->is_ellipse = false;
    shape->mode = 2;

    // For X11, we'll create a region from rectangles later
    // Store the pixel data info for now
    // This is complex - for simplicity, generate bounding polygon

    // Find bounding box of non-transparent pixels
    int minX = width, minY = height, maxX = 0, maxY = 0;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            if (ptr[y * width + x].a > tolerance) {
                if (x < minX) minX = x;
                if (x > maxX) maxX = x;
                if (y < minY) minY = y;
                if (y > maxY) maxY = y;
            }
        }
    }

    if (maxX >= minX && maxY >= minY) {
        shape->is_rect = true;
        shape->x1 = minX;
        shape->y1 = minY;
        shape->x2 = maxX + 1;
        shape->y2 = maxY + 1;
    }

    return shape;
}

#pragma endregion

#pragma region Shape Manipulation

gml_id<window_shape> window_shape_duplicate(gml_id<window_shape> shape) {
    if (!shape) return window_shape_create_empty();

    auto copy = new window_shape_data();
    *copy = *shape;
    return copy;
}

void window_shape_shift(gml_id<window_shape> shape, int x, int y) {
    if (!shape) return;

    if (shape->is_rect) {
        shape->x1 += x;
        shape->y1 += y;
        shape->x2 += x;
        shape->y2 += y;
    }
    if (shape->is_ellipse) {
        shape->cx += x;
        shape->cy += y;
    }
    for (auto& pt : shape->points) {
        pt.x += x;
        pt.y += y;
    }
}

gml_id<window_shape> window_shape_transform(gml_id<window_shape> shape, float m11, float m12, float m21, float m22, float dx, float dy) {
    if (!shape) return window_shape_create_empty();

    auto result = new window_shape_data();
    result->is_rect = false;
    result->is_ellipse = false;
    result->mode = shape->mode;

    // Transform all points
    if (shape->is_rect && shape->points.empty()) {
        // Generate rect corners
        int x1 = shape->x1, y1 = shape->y1, x2 = shape->x2, y2 = shape->y2;
        result->points.push_back({(int)(x1 * m11 + y1 * m21 + dx), (int)(x1 * m12 + y1 * m22 + dy)});
        result->points.push_back({(int)(x2 * m11 + y1 * m21 + dx), (int)(x2 * m12 + y1 * m22 + dy)});
        result->points.push_back({(int)(x2 * m11 + y2 * m21 + dx), (int)(x2 * m12 + y2 * m22 + dy)});
        result->points.push_back({(int)(x1 * m11 + y2 * m21 + dx), (int)(x1 * m12 + y2 * m22 + dy)});
    } else {
        for (auto& pt : shape->points) {
            result->points.push_back({
                (int)(pt.x * m11 + pt.y * m21 + dx),
                (int)(pt.x * m12 + pt.y * m22 + dy)
            });
        }
    }

    return result;
}

// Combine operations - simplified for Linux (mainly OR/union)
gml_id<window_shape> window_shape_combine(gml_id_destroy<window_shape> shape1, gml_id_destroy<window_shape> shape2, int op) {
    auto result = new window_shape_data();
    result->is_rect = false;
    result->is_ellipse = false;
    result->mode = 2;

    // For simplicity, just combine points (OR operation)
    // Full boolean ops would require complex polygon clipping
    if (shape1) {
        for (auto& pt : shape1->points) {
            result->points.push_back(pt);
        }
        delete shape1;
    }
    if (shape2) {
        for (auto& pt : shape2->points) {
            result->points.push_back(pt);
        }
        delete shape2;
    }

    return result;
}

gml_id<window_shape> window_shape_combine_nc(gml_id<window_shape> shape1, gml_id<window_shape> shape2, int op) {
    auto s1 = shape1 ? window_shape_duplicate(shape1) : nullptr;
    auto s2 = shape2 ? window_shape_duplicate(shape2) : nullptr;
    return window_shape_combine(s1, s2, op);
}

bool window_shape_concat(gml_id<window_shape> dest, gml_id<window_shape> shape, int op) {
    if (shape && dest) {
        for (auto& pt : shape->points) {
            dest->points.push_back(pt);
        }
    }
    if (shape) delete shape;
    return true;
}

bool window_shape_concat_nc(gml_id<window_shape> dest, gml_id<window_shape> shape, int op) {
    if (shape && dest) {
        for (auto& pt : shape->points) {
            dest->points.push_back(pt);
        }
    }
    return true;
}

#pragma endregion

#pragma region Shape Queries

bool window_shape_contains_point(gml_id<window_shape> shape, int x, int y) {
    if (!shape) return false;

    if (shape->is_rect) {
        return x >= shape->x1 && x < shape->x2 && y >= shape->y1 && y < shape->y2;
    }

    if (shape->is_ellipse) {
        double dx = (x - shape->cx) / (double)shape->rx;
        double dy = (y - shape->cy) / (double)shape->ry;
        return dx*dx + dy*dy <= 1.0;
    }

    // Point-in-polygon test (ray casting)
    if (shape->points.size() < 3) return false;

    int count = 0;
    size_t n = shape->points.size();
    for (size_t i = 0, j = n - 1; i < n; j = i++) {
        auto& pi = shape->points[i];
        auto& pj = shape->points[j];
        if (((pi.y > y) != (pj.y > y)) &&
            (x < (pj.x - pi.x) * (y - pi.y) / (pj.y - pi.y) + pi.x)) {
            count++;
        }
    }
    return (count % 2) == 1;
}

bool window_shape_contains_rectangle(gml_id<window_shape> shape, int x1, int y1, int x2, int y2) {
    return window_shape_contains_point(shape, x1, y1) &&
           window_shape_contains_point(shape, x2, y1) &&
           window_shape_contains_point(shape, x1, y2) &&
           window_shape_contains_point(shape, x2, y2);
}

#pragma endregion

#pragma region Window Operations

static XPoint* shape_to_xpoints(window_shape_data* shape, int& count) {
    if (shape->is_rect && shape->points.empty()) {
        count = 4;
        XPoint* pts = new XPoint[4];
        pts[0].x = shape->x1; pts[0].y = shape->y1;
        pts[1].x = shape->x2; pts[1].y = shape->y1;
        pts[2].x = shape->x2; pts[2].y = shape->y2;
        pts[3].x = shape->x1; pts[3].y = shape->y2;
        return pts;
    }

    count = shape->points.size();
    if (count == 0) return nullptr;

    XPoint* pts = new XPoint[count];
    for (int i = 0; i < count; i++) {
        pts[i].x = shape->points[i].x;
        pts[i].y = shape->points[i].y;
    }
    return pts;
}

void window_shape_set(gml_id_destroy<window_shape> shape) {
    if (!display || !window) {
        if (shape) delete shape;
        return;
    }

    if (shape) {
        int count;
        XPoint* pts = shape_to_xpoints(shape, count);

        if (pts && count >= 3) {
            Region region = XPolygonRegion(pts, count,
                shape->mode == 1 ? EvenOddRule : WindingRule);
            XShapeCombineRegion(display, window, ShapeBounding, 0, 0, region, ShapeSet);
            XDestroyRegion(region);
        }

        delete[] pts;
        delete shape;
    }

    XFlush(display);
}

void window_shape_set_nc(gml_id<window_shape> shape) {
    if (shape) {
        auto copy = window_shape_duplicate(shape);
        window_shape_set(copy);
    } else {
        window_shape_set(nullptr);
    }
}

void window_shape_reset() {
    if (!display || !window) return;
    XShapeCombineMask(display, window, ShapeBounding, 0, 0, None, ShapeSet);
    XFlush(display);
}

void window_shape_destroy(gml_id_destroy<window_shape> shape) {
    if (shape) delete shape;
}

#pragma endregion

#pragma region Initialization

dllx void window_shape_init_raw(void* _hwnd) {
    // On Linux, GameMaker passes the X11 Window ID
    window = (Window)(uintptr_t)_hwnd;

    // Get the display connection
    display = XOpenDisplay(nullptr);
}

#pragma endregion

#pragma region Alpha/Transparency

dllx void window_enable_per_pixel_alpha() {
    // X11 per-pixel alpha requires composite extension and ARGB visual
    // This is complex and depends on window manager support
    // For now, this is a no-op placeholder

    if (!display || !window) return;

    // Check for composite extension
    int event_base, error_base;
    if (XCompositeQueryExtension(display, &event_base, &error_base)) {
        // Composite is available
        // Would need to recreate window with ARGB visual for true per-pixel alpha
    }
}

dllx double window_get_alpha() {
    if (!display || !window) return 1.0;

    // Get _NET_WM_WINDOW_OPACITY property
    Atom opacity_atom = XInternAtom(display, "_NET_WM_WINDOW_OPACITY", False);
    Atom actual_type;
    int actual_format;
    unsigned long nitems, bytes_after;
    unsigned char* data = nullptr;

    if (XGetWindowProperty(display, window, opacity_atom, 0, 1, False,
                           XA_CARDINAL, &actual_type, &actual_format,
                           &nitems, &bytes_after, &data) == Success && data) {
        unsigned long opacity = *(unsigned long*)data;
        XFree(data);
        return (double)opacity / 0xFFFFFFFF;
    }

    return 1.0;
}

dllx void window_set_alpha(double alpha) {
    if (!display || !window) return;

    if (alpha < 0) alpha = 0;
    if (alpha > 1) alpha = 1;

    Atom opacity_atom = XInternAtom(display, "_NET_WM_WINDOW_OPACITY", False);
    unsigned long opacity = (unsigned long)(alpha * 0xFFFFFFFF);

    XChangeProperty(display, window, opacity_atom, XA_CARDINAL, 32,
                    PropModeReplace, (unsigned char*)&opacity, 1);
    XFlush(display);
}

// Chromakey - not supported on X11 in the same way as Windows
static double chromakeyColor = -1;

dllx double window_get_chromakey() {
    return chromakeyColor;
}

dllx void window_set_chromakey(double color) {
    chromakeyColor = color;
    // X11 doesn't have native chromakey support
}

#pragma endregion

#pragma region Raw wrapper functions (GML interface)

dllx double window_shape_create_empty_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    gml_id<window_shape> _ret = window_shape_create_empty();
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_create_rectangle_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    int _arg_x1 = _in.read<int>();
    int _arg_y1 = _in.read<int>();
    int _arg_x2 = _in.read<int>();
    int _arg_y2 = _in.read<int>();
    gml_id<window_shape> _ret = window_shape_create_rectangle(_arg_x1, _arg_y1, _arg_x2, _arg_y2);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_create_round_rectangle_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    int _arg_x1 = _in.read<int>();
    int _arg_y1 = _in.read<int>();
    int _arg_x2 = _in.read<int>();
    int _arg_y2 = _in.read<int>();
    int _arg_w = _in.read<int>();
    int _arg_h = _in.read<int>();
    gml_id<window_shape> _ret = window_shape_create_round_rectangle(_arg_x1, _arg_y1, _arg_x2, _arg_y2, _arg_w, _arg_h);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_create_ellipse_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    int _arg_x1 = _in.read<int>();
    int _arg_y1 = _in.read<int>();
    int _arg_x2 = _in.read<int>();
    int _arg_y2 = _in.read<int>();
    gml_id<window_shape> _ret = window_shape_create_ellipse(_arg_x1, _arg_y1, _arg_x2, _arg_y2);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_create_circle_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    int _arg_x = _in.read<int>();
    int _arg_y = _in.read<int>();
    int _arg_rad = _in.read<int>();
    gml_id<window_shape> _ret = window_shape_create_circle(_arg_x, _arg_y, _arg_rad);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_create_polygon_from_buffer_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    gml_buffer _arg_b = _in.read_gml_buffer();
    int _arg_mode = _in.read<int>();
    int _arg_count;
    if (_in.read<bool>()) {
        _arg_count = _in.read<int>();
    } else {
        _arg_count = -1;
    }
    gml_id<window_shape> _ret = window_shape_create_polygon_from_buffer(_arg_b, _arg_mode, _arg_count);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_create_polygon_from_path_data_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    gml_buffer _arg_b = _in.read_gml_buffer();
    int _arg_mode = _in.read<int>();
    bool _arg_closed = _in.read<bool>();
    bool _arg_smooth = _in.read<bool>();
    int _arg_precision = _in.read<int>();
    int _arg_count = _in.read<int>();
    gml_id<window_shape> _ret = window_shape_create_polygon_from_path_data(_arg_b, _arg_mode, _arg_closed, _arg_smooth, _arg_precision, _arg_count);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_create_rectangles_from_rgba_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    gml_buffer _arg_b = _in.read_gml_buffer();
    int _arg_tolerance = _in.read<int>();
    int _arg_width = _in.read<int>();
    int _arg_height = _in.read<int>();
    gml_id<window_shape> _ret = window_shape_create_rectangles_from_rgba(_arg_b, _arg_tolerance, _arg_width, _arg_height);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_duplicate_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    gml_id<window_shape> _arg_shape = (gml_id<window_shape>)_in.read<int64_t>();
    gml_id<window_shape> _ret = window_shape_duplicate(_arg_shape);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_shift_raw(void* _in_ptr, void* _in_ptr_size) {
    gml_istream _in(_in_ptr);
    gml_id<window_shape> _arg_shape = (gml_id<window_shape>)_in.read<int64_t>();
    int _arg_x = _in.read<int>();
    int _arg_y = _in.read<int>();
    window_shape_shift(_arg_shape, _arg_x, _arg_y);
    return 1;
}

dllx double window_shape_transform_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    gml_id<window_shape> _arg_shape = (gml_id<window_shape>)_in.read<int64_t>();
    float _arg_m11 = _in.read<float>();
    float _arg_m12 = _in.read<float>();
    float _arg_m21 = _in.read<float>();
    float _arg_m22 = _in.read<float>();
    float _arg_dx = _in.read<float>();
    float _arg_dy = _in.read<float>();
    gml_id<window_shape> _ret = window_shape_transform(_arg_shape, _arg_m11, _arg_m12, _arg_m21, _arg_m22, _arg_dx, _arg_dy);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_combine_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    gml_id_destroy<window_shape> _arg_shape1 = (gml_id_destroy<window_shape>)_in.read<int64_t>();
    gml_id_destroy<window_shape> _arg_shape2 = (gml_id_destroy<window_shape>)_in.read<int64_t>();
    int _arg_op = _in.read<int>();
    gml_id<window_shape> _ret = window_shape_combine(_arg_shape1, _arg_shape2, _arg_op);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_combine_nc_raw(void* _inout_ptr, void* _inout_ptr_size) {
    gml_istream _in(_inout_ptr);
    gml_id<window_shape> _arg_shape1 = (gml_id<window_shape>)_in.read<int64_t>();
    gml_id<window_shape> _arg_shape2 = (gml_id<window_shape>)_in.read<int64_t>();
    int _arg_op = _in.read<int>();
    gml_id<window_shape> _ret = window_shape_combine_nc(_arg_shape1, _arg_shape2, _arg_op);
    gml_ostream _out(_inout_ptr);
    _out.write<int64_t>((int64_t)_ret);
    return 1;
}

dllx double window_shape_concat_raw(void* _in_ptr, void* _in_ptr_size) {
    gml_istream _in(_in_ptr);
    gml_id<window_shape> _arg_dest = (gml_id<window_shape>)_in.read<int64_t>();
    gml_id<window_shape> _arg_shape = (gml_id<window_shape>)_in.read<int64_t>();
    int _arg_op = _in.read<int>();
    return window_shape_concat(_arg_dest, _arg_shape, _arg_op);
}

dllx double window_shape_concat_nc_raw(void* _in_ptr, void* _in_ptr_size) {
    gml_istream _in(_in_ptr);
    gml_id<window_shape> _arg_dest = (gml_id<window_shape>)_in.read<int64_t>();
    gml_id<window_shape> _arg_shape = (gml_id<window_shape>)_in.read<int64_t>();
    int _arg_op = _in.read<int>();
    return window_shape_concat_nc(_arg_dest, _arg_shape, _arg_op);
}

dllx double window_shape_contains_point_raw(void* _in_ptr, void* _in_ptr_size) {
    gml_istream _in(_in_ptr);
    gml_id<window_shape> _arg_shape = (gml_id<window_shape>)_in.read<int64_t>();
    int _arg_x = _in.read<int>();
    int _arg_y = _in.read<int>();
    return window_shape_contains_point(_arg_shape, _arg_x, _arg_y);
}

dllx double window_shape_contains_rectangle_raw(void* _in_ptr, void* _in_ptr_size) {
    gml_istream _in(_in_ptr);
    gml_id<window_shape> _arg_shape = (gml_id<window_shape>)_in.read<int64_t>();
    int _arg_x1 = _in.read<int>();
    int _arg_y1 = _in.read<int>();
    int _arg_x2 = _in.read<int>();
    int _arg_y2 = _in.read<int>();
    return window_shape_contains_rectangle(_arg_shape, _arg_x1, _arg_y1, _arg_x2, _arg_y2);
}

dllx double window_shape_set_raw(void* _in_ptr, void* _in_ptr_size) {
    gml_istream _in(_in_ptr);
    gml_id_destroy<window_shape> _arg_shape = (gml_id_destroy<window_shape>)_in.read<int64_t>();
    window_shape_set(_arg_shape);
    return 1;
}

dllx double window_shape_set_nc_raw(void* _in_ptr, void* _in_ptr_size) {
    gml_istream _in(_in_ptr);
    gml_id<window_shape> _arg_shape = (gml_id<window_shape>)_in.read<int64_t>();
    window_shape_set_nc(_arg_shape);
    return 1;
}

dllx double window_shape_reset_raw(void* _in_ptr, void* _in_ptr_size) {
    gml_istream _in(_in_ptr);
    window_shape_reset();
    return 1;
}

dllx double window_shape_destroy_raw(void* _in_ptr, void* _in_ptr_size) {
    gml_istream _in(_in_ptr);
    gml_id_destroy<window_shape> _arg_shape = (gml_id_destroy<window_shape>)_in.read<int64_t>();
    window_shape_destroy(_arg_shape);
    return 1;
}

#pragma endregion
