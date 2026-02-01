surface = surface_create(RES_WIDTH, RES_HEIGHT);
surHeight = RES_HEIGHT;

xTo = 0.5;
yTo = 0.5;
scaleTo = 1.2;

image_xscale = scaleTo;
image_yscale = scaleTo;
x = RES_WIDTH * xTo;
y = RES_HEIGHT * yTo;

wait = 15;


phase = -1;
introPercent = 0;
phasePercent = 0;
introCurve = animcurve_get_channel(MenuCurves, "logo");

audio_stop_all();
audio_play_sound(mMusic, 1, true, 1, 3.2 - (1 / 0.012 + wait) / 60);
