/// @desc 

mask.Update();

if (transitionPercent == 1 and leading) {
	leading = false;
	room_goto(targetRoom);
} else {
	transitionPercent = Approach(transitionPercent, leading, transitionSpd);
	if (transitionPercent == 0) {
        global.gameState = GameState.NORMAL;
		instance_destroy();
	}
    
    var _camY = camera_get_view_y(view_camera[0]);
    if (leading) {
        mask.y = lerp(_camY + RES_HEIGHT + 20, _camY - 20, transitionPercent);
    } else {
        mask.y = lerp(_camY - 20 - mask.Height, _camY + RES_HEIGHT + 20 - mask.Height, transitionPercent);
    }
}
