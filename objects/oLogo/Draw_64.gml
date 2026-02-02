if (phase == 0) {
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_font(fSpace);
    
    draw_set_alpha(phasePercent);
    draw_text_transformed(RES_WIDTH / 2 - (1 - phasePercent) * 10, RES_HEIGHT / 2 + 84 + Wave(-4, 4, 2, 0.8), "PRESS START", 0.6, 0.6, 4.5);
    
    if (OPERA) {
        draw_set_colour(c_grey);
        draw_text_transformed(RES_WIDTH / 2 - (1 - phasePercent) * 10 - 100, RES_HEIGHT / 2 + 100 + Wave(-4, 4, 2, 0.7), "DESKTOP VER\nRECOMMENDED", 0.3, 0.3, 4.5);
    }
    
    draw_set_alpha(1);
}