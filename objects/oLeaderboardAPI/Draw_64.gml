/// @desc 

if (draw) {
	draw_set_font(fScore);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	
	var _x = 72;
	var _y = 62;
	
	draw_text(_x+8, _y, "PLACE");
	draw_text(_x+42, _y, "NAME");
    if (global.gxGames) {
        draw_text(_x+106, _y, "SCORE");
    } else {
    	draw_text(_x+80, _y, "SCORE");
    	draw_text(_x+106, _y, "ROUND");
    }
	
	draw_set_halign(fa_left);
	
	for(var i = max(0, scoreOffsetTarget-round(1*scrollSpd)); i < min(array_length(scores), scoreOffsetTarget+scoresPerPage+round(1*scrollSpd)); i++) {
        if (global.gxGames)
            draw_set_color((scores[i].userID == global.userID) ? c_yellow : c_white);
        else
            draw_set_color((scores[i].name == global.username) ? c_yellow : c_white);
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
		
		draw_text(_scoreX, _scoreY, _place);
        var _stringScale = 1;
        if (!global.gxGames) {
            _stringScale = 46 / max(46, string_width(scores[i].name));
        }
		draw_text_transformed(_x+22, _scoreY, scores[i].name, _stringScale, 1, 0);
        if (global.gxGames) {
            draw_text(_x+96, _scoreY, scores[i].points);
        } else {
            draw_text(_x+70, _scoreY, scores[i].points);
            draw_text(_x+104, _scoreY, scores[i].level);
        }
		
	}
	draw_set_alpha(1);
	
	if (scoreOffsetTarget != 0) {
		draw_sprite(sArrow, 0, RES_WIDTH/2, _y+18);	
	}
	
	if (scoreOffsetTarget < array_length(scores)-scoresPerPage) {
		draw_sprite_ext(sArrow, 0, RES_WIDTH/2, _y+94, 1, -1, 0, c_white, 1);	
	}
	
	draw_set_color(c_dkgray);
	draw_set_halign(fa_center);
	draw_text(RES_WIDTH/2,170,"PRESS ENTER TO");
	draw_text(RES_WIDTH/2,178,"CONTINUE");
}