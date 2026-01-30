/// @desc Create Mask

// Handle flip
if (image_xscale < 0) {
    image_angle = 90 - (image_angle - 90);
    image_xscale = -image_xscale;
    xTo = RES_WIDTH - xTo;
}

mask = new MaskBasicRectangle();
mask.x = x;
mask.y = y;

mask.SetSize(sprite_width, sprite_height, image_angle);
