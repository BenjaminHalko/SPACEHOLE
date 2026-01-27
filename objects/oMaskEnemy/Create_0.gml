/// @desc Setup Enemy

// Config
growSpeed = 2;
maxGrow = 4;
attackShrink = 1;

// State
attackPulse = 0;
targetSize = 2;
dead = false;
offsetTiming = 5;

// Create mask
mask = new MaskBasicCircle();
mask.x = x;
mask.y = y;
