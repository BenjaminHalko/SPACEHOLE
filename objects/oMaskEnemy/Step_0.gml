/// @desc Enemy behaviour

// Offset
mask.UpdateOffsets();

// Grow
targetSize = Approach(targetSize, maxGrow, growSpeed / 60);

// Update Mask
mask.size = ApproachEase(mask.size, targetSize, 0.1, 0.8);
mask.Update();
