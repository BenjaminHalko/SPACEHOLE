/// @desc Create Mask

event_inherited();

// Handle flip
if (flipped) {
    image_angle = 90 - (image_angle - 90);
    image_xscale = -image_xscale;
}

xscale = image_xscale;
yscale = image_yscale;
doorPercent = (doorID == -1 ? 1 : 0);

if (doorID != -1) {
    image_xscale = 1;
    image_yscale = 1;
}

mask = new MaskBasicRectangle();
mask.x = x;
mask.y = y;

mask.SetSize(sprite_width, sprite_height, image_angle);
