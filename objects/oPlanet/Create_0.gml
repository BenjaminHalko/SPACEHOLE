/// @desc Setup Enemy

event_inherited();

// Config
growSpeed = 2;
maxGrow = 0;
attackShrink = 1;
radius = 24;

// State
attackPulse = 0;
targetSize = 0;
dead = false;
offsetTiming = 5;

// Create mask
mask = new MaskBasicCircle();
mask.x = x;
mask.y = y;

death = 0;
deathCurve = animcurve_get_channel(PlayerCurves, "burn");

// Color palette based on position: [colorA r,g,b, colorB r,g,b, dissolve r,g,b]
var _palettes = [
    [0.8, 0.2, 0.1,   1.0, 0.6, 0.2,   1.0, 1.0, 0.0],  // Red/Orange → yellow dissolve
    [0.1, 0.3, 0.8,   0.2, 0.8, 0.6,   1.0, 1.0, 1.0],  // Blue/Teal → white dissolve
    [0.6, 0.1, 0.7,   1.0, 0.4, 0.6,   1.0, 0.0, 1.0],  // Purple/Pink → bright magenta dissolve
    [0.1, 0.6, 0.2,   0.8, 1.0, 0.3,   1.0, 1.0, 0.0],  // Green/Yellow → yellow dissolve
];
var _seed = instance_number(oPlanet) mod array_length(_palettes);
var _p = _palettes[_seed];
colorA = [_p[0], _p[1], _p[2]];
colorB = [_p[3], _p[4], _p[5]];
colorDissolve = [_p[6], _p[7], _p[8]];
