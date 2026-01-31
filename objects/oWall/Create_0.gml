/// @desc Init

event_inherited();

sprite_index = sWall;

// Handle flip
if (flipped) {
    image_angle = 90 - (image_angle - 90);
    image_xscale = -image_xscale;
}
