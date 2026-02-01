/// @desc 

draw_set_color(image_blend);

draw_set_alpha(image_alpha);
var _mat_trf_rot_z = matrix_build(x, y, 0, 0, 0, image_angle, 1, 1, 1);
matrix_set(matrix_world, _mat_trf_rot_z);
draw_ellipse(-size, -size*2, size, size*2, true);
matrix_set(matrix_world, matrix_build_identity());
draw_set_alpha(1);