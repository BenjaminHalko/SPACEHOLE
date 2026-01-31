/// @desc Draw black hole effect

var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);

// Draw mask to surface with gradient falloff
var _mat_trf_rot_z = matrix_build(-_camX, -_camY, 0, 0, 0, 0, 1, 1, 1);
matrix_set(matrix_world, _mat_trf_rot_z);
surface_set_target(maskSurface);
draw_clear(c_black);
draw_set_colour(c_white);
with(pMask) {
    mask.Draw();
}
surface_reset_target();
matrix_set(matrix_world, matrix_build_identity());

// Apply shader with mask

//shader_set(shBlackHole);
//texture_set_stage(uMaskTexture, surface_get_texture(maskSurface));
draw_surface(application_surface, 0, 0);
//shader_reset();
