/// @desc Draw BG

with (all) {
    event_user(1);
}

var _camX = oCamera.x - oCamera.viewWidthHalf;
var _camY = oCamera.y - oCamera.viewHeightHalf;
var _mat_trf_rot_z = matrix_build(-_camX, -_camY, 0, 0, 0, 0, 1, 1, 1);
matrix_set(matrix_world, _mat_trf_rot_z);

surface_set_target(surface);
draw_clear(c_black);

with (all) {
    event_user(0);
}

gpu_set_blendmode(bm_subtract);

with (oMaskEnemy) {
    mask.Draw();
}

gpu_set_blendmode(bm_normal);
surface_reset_target();

matrix_set(matrix_world, matrix_build_identity());
draw_surface(surface, _camX, _camY);

