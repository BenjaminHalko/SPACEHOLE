/// @desc Draw black hole effect

var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);



// Apply shader
shader_set(shBlackHole);
draw_surface(application_surface, 0, 0);
shader_reset();
