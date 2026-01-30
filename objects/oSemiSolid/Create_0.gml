/// @desc Init

// Handle flip
if (image_xscale < 0) {
    image_angle = 90 - (image_angle - 90);
    image_xscale = -image_xscale;
}
