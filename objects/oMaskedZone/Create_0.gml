/// @desc Create Mask

event_inherited();

// Handle flip
if (flipped) {
    image_angle = 90 - (image_angle - 90);
    image_xscale = -image_xscale;
}

mask = new MaskBasicRectangle();
mask.x = x;
mask.y = y;

mask.SetSize(sprite_width, sprite_height, image_angle);
