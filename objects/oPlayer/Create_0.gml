// Speed
hsp = 0;
vsp = 0;
moveSpd = 4;
grv = 0.3;

deathSpd = 1 / 60 / 3;
deathRecovery = 3 / 60;

// Not Speed
death = 0;
radius = 16;
image_angle = 0;
dashTimer = 0;

// Wall contact / jump
wallContact = false;
wallNormalX = 0;
wallNormalY = -1;
jumpStrength = 8;
jumpUpBias = 0.8; // 0 = pure normal, 1 = pure up
wallFriction = 0.98; // 0 = full stop, 1 = no friction

// Swing
swingTarget = oMaskEnemy;
swinging = false;
swingingPrev = false;
swingSpeed = 0;
ropeLength = 90;

sides = 5;

lightning = new LightningEffect();
