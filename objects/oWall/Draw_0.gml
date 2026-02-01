draw_self();

var _col1 = c_purple;
var _col2 = c_blue;

if (object_index == oSemiSolid) {
    _col1 = merge_colour(_col1, c_purple, 0.7);
    _col2 = merge_colour(_col2, c_black, 0.7);
}

gpu_set_colourwriteenable(1, 1, 1, 0);
draw_set_alpha(object_index == oSemiSolid ? 0.6 : 0.2);
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
