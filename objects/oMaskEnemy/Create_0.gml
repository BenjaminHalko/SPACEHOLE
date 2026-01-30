/// @desc Setup Enemy

event_inherited();

// Config
growSpeed = 2;
maxGrow = 0;
attackShrink = 1;

// State
attackPulse = 0;
targetSize = 0;
dead = false;
offsetTiming = 5;

// Create mask
mask = new MaskBasicCircle();
mask.x = x;
mask.y = y;
