/// @desc 

if (draw) {
	Input();
	if(disableSelect) {
		keySelect = false;
		disableSelect = false;
	}
	if (scoreOffset == scoreOffsetTarget) {
		if (array_length(scores)-scoresPerPage <= 0) {
			scoreOffsetTarget = 0;
		} else {
			scoreOffsetTarget = median(scoreOffsetTarget + round((keyDown - keyUp)*max(scrollSpd - 1, 1)), 0, array_length(scores)-scoresPerPage);
		}
	}
	scoreOffset = Approach(scoreOffset, scoreOffsetTarget, max(scrollSpd - 1, 1)*0.4);
    if (keyDown - keyUp != 0) {
        scrollSpd += 0.05;
        moved = true;
    } else {
        scrollSpd = 1;
    }
	
	if (keySelect) {
	}
}
	