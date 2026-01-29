/// @desc Draw BG

with (all) {
    event_user(1);
}

var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);
var _mat_trf_rot_z = matrix_build(-_camX, -_camY, 0, 0, 0, 0, 1, 1, 1);
matrix_set(matrix_world, _mat_trf_rot_z);

surface_set_target(surface);
draw_rectangle_colour(_camX, _camY, _camX + RES_WIDTH, _camY + RES_HEIGHT, #000030, #000030, #000020, #000020, false);

with (all) {
    event_user(0);
}

gpu_set_blendmode(bm_subtract);

with (pMask) {
    mask.Draw();
}

gpu_set_blendmode(bm_normal);
surface_reset_target();

matrix_set(matrix_world, matrix_build_identity());
draw_surface(surface, _camX, _camY);
