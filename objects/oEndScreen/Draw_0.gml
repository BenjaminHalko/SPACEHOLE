/// @desc 5

var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);

var _wave = Wave(-4, -10, 3, 0);

draw_set_colour(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fSpace);


if (room ==rGameEnd) {
    draw_text(_camX+RES_WIDTH/2, _camY+RES_HEIGHT / 6 + Wave(-5, 5, 3, 0.2), $"- GAME -\nCOMPLETE!");

    draw_set_valign(fa_top);
    draw_text_transformed(_camX+RES_WIDTH / 4 * 3, _camY+RES_HEIGHT / 4 * 3, DisplayNumber(global.pb[$ $"lvAll"]), 1, 1, _wave);
} else {
    draw_text(_camX+RES_WIDTH/2, _camY+RES_HEIGHT / 6 + Wave(-5, 5, 3, 0.2), $"- {global.levelNames[global.level]} -\nCOMPLETE!");

    draw_set_valign(fa_top);
    draw_text_transformed(_camX+RES_WIDTH / 4 * 3, _camY+RES_HEIGHT / 4 * 3, DisplayNumber(global.pb[$ $"lv{global.level}"]), 1, 1, _wave);
}

draw_text_transformed(_camX+RES_WIDTH / 4 * 3, _camY+RES_HEIGHT / 7 * 3, DisplayNumber(scoreDisplay), 1, 1, _wave);

draw_set_valign(fa_bottom);
draw_text_transformed(_camX+RES_WIDTH / 4 * 3, _camY+RES_HEIGHT / 7 * 3, "TIME", 0.5, 0.5, _wave);

draw_text_transformed(_camX+RES_WIDTH / 4 * 3, _camY+RES_HEIGHT / 4 * 3, "BEST", 0.5, 0.5, _wave);
