/// @desc Update Masks

event_inherited();

if (doorID == -1 and doorPercent != 1) {
    doorPercent = ApproachEase(doorPercent, 1, 0.1, 0.8);
    image_xscale = xscale * doorPercent;
    image_yscale = yscale * doorPercent;
    
    mask.SetSize(sprite_width, sprite_height, image_angle);
}

mask.x = x;
mask.y = y;

mask.UpdateOffsets();
mask.Update();
