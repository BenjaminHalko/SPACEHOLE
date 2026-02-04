if (global.gameState != GameState.END and room != rMenu and room != rGameEnd and (!instance_exists(oTransition) or (oTransition.targetRoom != rGameEnd and oTransition.targetRoom != rMenu))) {
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(fSpace);
    
    draw_text_transformed(5, 5, DisplayNumber(global.score), 0.5, 0.5, 0);
    
    if (global.gameScore != -1) {
        draw_set_colour(c_grey);
        draw_text_transformed(5, 24, DisplayNumber(global.gameScore), 0.3, 0.3, 0);
    }
}