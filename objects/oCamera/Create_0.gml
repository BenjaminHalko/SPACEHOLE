/// @desc Set up camera
cam = view_camera[0];
viewWidthHalf = RES_WIDTH * 0.5;
viewHeightHalf = RES_HEIGHT * 0.5;
follow = oPlayer;
xOffset = 0;

shakeLength = 0;
shakeMagnitude = 0;
shakeRemain = 0;

x = follow.x;
y = follow.y;
