/// @desc Init

event_inherited();

sprite_index = sWallTexture;

image_xscale *= (sprite_get_width(sWall) / sprite_get_width(sWallTexture));
image_yscale *= (sprite_get_height(sWall) / sprite_get_height(sWallTexture));

// Handle flip
if (flipped) {
    image_angle = 90 - (image_angle - 90);
    image_xscale = -image_xscale;
}
