/// @desc Draw Background


var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);

draw_set_colour(c_black);
shader_set(shBackground);

draw_rectangle(_camX, _camY, _camX + RES_WIDTH, _camY + RES_HEIGHT, false);

shader_reset();
