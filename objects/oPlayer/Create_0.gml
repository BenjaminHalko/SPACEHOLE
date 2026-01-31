// Speed
hsp = 0;
vsp = -2;
moveSpd = 4;
grv = 0.3;

deathSpd = 1 / 60 / 2;
deathRecovery = 2 / 60;

// Not Speed
death = 0;
deathCurve = animcurve_get_channel(PlayerCurves, "burn");
radius = 16;
image_angle = 0;
dashTimer = 0;
jumpTimer = 0;

// Wall contact / jump
wallContact = noone;
wallNormalX = 0;
wallNormalY = -1;
jumpStrength = 8;
jumpUpBias = 0.8; // 0 = pure normal, 1 = pure up
wallFriction = 1; // 0 = full stop, 1 = no friction
flipperFriction = 0.9; // 0 = full stop, 1 = no friction

// Swing
swingTarget = noone;
swinging = false;
swingingPrev = false;
swingSpeed = 0;
ropeLength = 90;

sides = 5;

lightning = new LightningEffect();
