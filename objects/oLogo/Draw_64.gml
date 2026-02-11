if (phase == 0) {
    draw_set_color(c_white);
    draw_set_halign(MOBILE ? fa_center : fa_left);
    draw_set_valign(fa_middle);
    draw_set_font(fSpace);
    
    var _scale = RES_HEIGHT / RES_WIDTH;
    
    draw_set_alpha(phasePercent);
    draw_text_transformed(RES_WIDTH / 2 - (1 - phasePercent) * 10 * (!MOBILE), RES_HEIGHT * (0.73 + Wave(-0.02, 0.02, 2, 0.8)), MOBILE ? "TAP ANYWHERE" : "PRESS START", 0.6 * _scale, 0.6 * _scale, 4.5);
    
    if (OPERA and !MOBILE) {
        draw_set_colour(c_grey);
        draw_text_transformed(RES_WIDTH / 2 - (1 - phasePercent) * 10 - 100, RES_HEIGHT / 2 + 100 + Wave(-4, 4, 2, 0.7), "DESKTOP VER\nRECOMMENDED", 0.3, 0.3, 4.5);
    }
    
    if (MOBILE) {
        draw_set_colour(c_grey);

        if (editingUsername or global.username != "") draw_text_transformed(RES_WIDTH/2, RES_HEIGHT * 0.04, "USERNAME", _scale * 0.5, _scale * 0.5, 0);
        draw_text_transformed(RES_WIDTH/2, RES_HEIGHT * 0.1, global.username, _scale, _scale, Wave(-4, 4, 2, 0));
    }
    
    
    draw_set_alpha(1);
}