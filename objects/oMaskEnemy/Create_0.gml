/// @desc Setup Enemy

// Config
growSpeed = 0.5;
maxGrow = 3;
attackShrink = 0.2;

// State
attackPulse = 0;
targetSize = 0;
dead = false;
offsetTiming = 5;

// Create mask
mask = new MaskBasicCircle();
mask.x = x;
mask.y = y;
