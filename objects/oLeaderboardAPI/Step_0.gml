/// @desc 

if (draw) {
	Input();
	if (scoreOffset == scoreOffsetTarget) {
        var _scores = scores[$ showAll ? "lvAll" : $"lv{global.level}"];
		if (array_length(_scores)-scoresPerPage <= 0) {
			scoreOffsetTarget = 0;
		} else {
			scoreOffsetTarget = median(scoreOffsetTarget + round((keyDown - keyUp)*max(scrollSpd - 1, 1)), 0, array_length(_scores)-scoresPerPage);
		}
	}
	scoreOffset = Approach(scoreOffset, scoreOffsetTarget, max(scrollSpd - 1, 1)*0.4);
    if (keyDown - keyUp != 0) {
        scrollSpd += 0.05;
        moved = true;
    } else {
        scrollSpd = 1;
    }
}
	