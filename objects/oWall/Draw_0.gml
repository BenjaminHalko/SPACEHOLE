draw_self();

var _col1 = c_purple;
var _col2 = c_blue;

gpu_set_colourwriteenable(1, 1, 1, 0);
draw_set_alpha(0.2);
draw_triangle_colour(
    x + corners[0][0], y + corners[0][1],
    x + corners[1][0], y + corners[1][1],
    x + corners[2][0], y + corners[2][1],
    _col1,
    _col1,
    _col2,
    false);

draw_triangle_colour(
    x + corners[0][0], y + corners[0][1],
    x + corners[3][0], y + corners[3][1],
    x + corners[2][0], y + corners[2][1],
    _col1,
    _col2,
    _col2,
    false);
draw_set_alpha(1);
gpu_set_colourwriteenable(1, 1, 1, 1);
