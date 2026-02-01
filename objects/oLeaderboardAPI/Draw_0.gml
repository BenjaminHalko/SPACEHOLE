/// @desc 


if (draw) {
    var _camX = camera_get_view_x(view_camera[0]);
    var _camY = camera_get_view_y(view_camera[0]);
    
	draw_set_font(fFont);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	
	var _x = 72 + _camX;
	var _y = RES_HEIGHT / 3 + _camY;
	
	draw_text(_x-10, _y, "PLACE");
	draw_text(_x+42, _y, "NAME");
    draw_text(_x+106, _y, "SCORE");
	
	draw_set_halign(fa_left);
    
    var _scores = scores[$ $"lv{global.level}"];
	
	for(var i = max(0, scoreOffsetTarget-round(1*scrollSpd)); i < min(array_length(_scores), scoreOffsetTarget+scoresPerPage+round(1*scrollSpd)); i++) {
        if (global.gxGames)
            draw_set_color((_scores[i].userID == global.userID) ? c_yellow : c_white);
        else
            draw_set_color((_scores[i].name == global.username) ? c_yellow : c_white);
		draw_set_alpha(1 - median(0, 1, abs((i - scoreOffset) - 3.5) - 3.5));
		var _scoreY = _y + (i - scoreOffset) * 9 + 16;
        var _scoreX = _x;
        if (i >= 999)
            _scoreX -= 4;
		
		var _place = string(i + 1);
		if ((i+1) % 10 == 1 and (i+1) % 100 != 11) _place += "st";
		else if ((i+1) % 10 == 2 and (i+1) % 100 != 12) _place += "nd";
		else if ((i+1) % 10 == 3 and (i+1) % 100 != 13) _place += "rd";
		else _place += "th";
		
		draw_text(_scoreX-18, _scoreY, _place);
        var _stringScale = 1;
        if (!global.gxGames) {
            //_stringScale = 46 / max(46, string_width(_scores[i].name));
        }
		draw_text_transformed(_x+22, _scoreY, _scores[i].name, _stringScale, 1, 0);
        draw_text(_x+88, _scoreY, DisplayNumber(_scores[i].points));
		
	}
	draw_set_alpha(1);
	
	if (scoreOffsetTarget != 0) {
		draw_sprite(sArrow, 0, RES_WIDTH/2, _y+18);	
	}
	
	if (scoreOffsetTarget < array_length(_scores)-scoresPerPage) {
		draw_sprite_ext(sArrow, 0, RES_WIDTH/2, _y+94, 1, -1, 0, c_white, 1);	
	}
}