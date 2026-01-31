/// @desc Enemy behaviour

event_inherited();

death = ApproachEase(death, (oPlayer.swingTarget == id and oPlayer.swinging) ? oPlayer.death : 0, 0.05, 0.8);

// Offset
mask.UpdateOffsets();

// Grow
targetSize = Approach(targetSize, maxGrow, growSpeed / 60);

// Update Mask
mask.size = ApproachEase(mask.size, targetSize, 0.1, 0.8);
mask.Update();
