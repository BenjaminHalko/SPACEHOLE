/// @desc Init

event_inherited();

sprite_index = sWallTexture;

image_xscale *= (sprite_get_width(sWall) / sprite_get_width(sWallTexture));
image_yscale *= (sprite_get_height(sWall) / sprite_get_height(sWallTexture));

var _width = sprite_width;
var _height = sprite_height;
var _rotation = image_angle;
var _dir = point_direction(0, 0, _width / 2, -_height / 2);
var _dist = point_distance(0, 0, _width / 2, _height / 2);

corners = [
    [lengthdir_x(_dist, 180 - _dir + _rotation), lengthdir_y(_dist, 180 - _dir + _rotation)],
    [lengthdir_x(_dist, _dir + _rotation), lengthdir_y(_dist, _dir + _rotation)],
    [lengthdir_x(_dist, -_dir + _rotation), lengthdir_y(_dist, -_dir + _rotation)],
    [lengthdir_x(_dist, 180 + _dir + _rotation), lengthdir_y(_dist, 180 + _dir + _rotation)]
]

// Handle flip
if (flipped) {
    image_angle = 90 - (image_angle - 90);
    image_xscale = -image_xscale;
}
