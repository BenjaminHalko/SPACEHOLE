/// @desc Bounce

if (place_meeting(x, y, oPlayer)) {
    var _dir = point_direction(x, y, oPlayer.x, oPlayer.y);
    var _bounceSpd = 8;
    oPlayer.hsp = lengthdir_x(_bounceSpd, _dir);
    oPlayer.vsp = lengthdir_y(_bounceSpd, _dir);
}
