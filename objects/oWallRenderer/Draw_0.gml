var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);

surface_set_target(wallSurface);
draw_clear_alpha(c_black, 0);

var _mat_trf_rot_z = matrix_build(-_camX, -_camY, 0, 0, 0, 0, 1, 1, 1);
matrix_set(matrix_world, _mat_trf_rot_z);

with(oWall) {
    draw_self();
}

//matrix_set(matrix_world, matrix_build_identity());

gpu_set_colourwriteenable(1, 1, 1, 0);
draw_sprite_tiled_ext(sWallTexture, 0, _camX, _camY-(_camY mod texHeight), 1, 1, c_white, 1);
gpu_set_colourwriteenable(1, 1, 1, 1);

with(oWall) {
    // draw_sprite_ext(sWall, 1, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
}

surface_reset_target();
matrix_set(matrix_world, matrix_build_identity());


draw_surface(wallSurface, _camX, _camY);
