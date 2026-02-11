surface_set_target(surface);
draw_clear_alpha(c_black, 0);

if (phase == -1) {
    var _percent = 0.1 + (1 - animcurve_channel_evaluate(introCurve, introPercent)) * 0.8;
    y = RES_HEIGHT * (0.5 - _percent);
    draw_sprite_ext(sprite_index, 1, RES_WIDTH * 0.5, RES_HEIGHT * (0.5 - _percent), scaleTo, scaleTo, 0, c_white, 1);
    draw_sprite_ext(sprite_index, 2, RES_WIDTH * 0.5, RES_HEIGHT * (0.5 + _percent), scaleTo, scaleTo, 0, c_white, 1);
} else {
    draw_self();
}


gpu_set_colourwriteenable(1, 1, 1, 0);

var _alpha = (phase == 0) ? introPercent : 1;

if (phase == -1) {
    var _y = RES_HEIGHT * (0.5 + _percent);
    draw_sprite_ext(sWallTexture, 0, x, _y, 4, 3, 0, c_white, _alpha);
}

draw_sprite_ext(sWallTexture, 0, x, y + Wave(-4, 4, 2, 0.1) * (phase != -1), 10, 4 + (phase != -1), 0, c_white, _alpha);

if (phase != -1) {
    var _col1 = c_white;
    var _col2 = c_blue;
    draw_set_alpha(0.2 * _alpha);
    draw_rectangle_colour(bbox_left, bbox_top, bbox_right, bbox_bottom, _col1, _col1, _col2, _col2, false);
    draw_set_alpha(1);
}

gpu_set_colourwriteenable(1, 1, 1, 1);

surface_reset_target();


var _camY = camera_get_view_y(view_camera[0]);

draw_surface_ext(surface, 3, _camY + 3, 1, 1, 0, c_black, 1);
shader_set(shVibrance);
draw_surface(surface, 0, _camY);
shader_reset();
