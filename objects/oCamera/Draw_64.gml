if (global.gameState == GameState.NORMAL and room != rMenu) {
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(fSpace);
    
    draw_text_transformed(5, 5, DisplayNumber(global.score), 0.5, 0.5, 0);
}