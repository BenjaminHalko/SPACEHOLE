/// @desc Enemy behaviour

image_index = (oPlayer.swingTarget == id and oPlayer.swinging);

// Offset
mask.UpdateOffsets();

// Grow
targetSize = Approach(targetSize, maxGrow, growSpeed / 60);

// Update Mask
mask.size = ApproachEase(mask.size, targetSize, 0.1, 0.8);
mask.Update();
