/// @desc Init

event_inherited();

// Handle flip
if (flipped) {
    image_xscale = -image_xscale;
    image_angle = -image_angle;
}
