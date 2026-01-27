/// @desc Enemy behaviour

// Attack
if (keyboard_check_pressed(vk_space)) {
    attackPulse = 1;
    targetSize = max(0, targetSize - attackShrink);
}

// Offset
mask.UpdateOffsets();

// Grow
targetSize = Approach(targetSize, maxGrow, growSpeed / 60);

// Update Mask
mask.size = ApproachEase(mask.size, targetSize, 0.1, 0.8);
mask.Update();
