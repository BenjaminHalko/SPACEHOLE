draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(fSpace);

var _camY = camera_get_view_y(view_camera[0]);

var _menuX = RES_WIDTH / 2 + 40;
var _menuY = RES_HEIGHT / 2 + _camY;

draw_text_transformed(_menuX - 20, _menuY + menuCursorY - 6, ">", 1, 1, 0);

for (var i = 0; i < global.maxLevels; i++) {
    if (!start or (i == global.level and blink mod 2 == 1)) {
        draw_text_transformed(_menuX, _menuY, global.levelNames[i], 0.6, 0.6, 0);
    }
    _menuY += 32;
}

draw_sprite(sScreenshots, global.level, _menuX, RES_HEIGHT / 2 + _camY);
