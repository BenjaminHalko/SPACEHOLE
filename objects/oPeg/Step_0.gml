/// @desc Bounce

if (deactive <= 0) {
    if (place_meeting(x, y, oPlayer) and !PointIsMasked(x, y)) {
        var _dir = point_direction(x, y, oPlayer.x, oPlayer.y);
        var _bounceSpd = 4;
        oPlayer.hsp = lengthdir_x(_bounceSpd, _dir);
        oPlayer.vsp = lengthdir_y(_bounceSpd, _dir);
        
        scale = 1.5;
        deactive = 1;
        
        ScreenShake(5, 5);
    }
} else {
    deactive -= 1 / 30;
}

scale = ApproachEase(scale, 1, 0.1, 0.8);
