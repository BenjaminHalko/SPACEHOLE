/// @desc Set up camera
cam = view_camera[0];
camera_set_view_size(cam, RES_WIDTH, RES_HEIGHT);
viewWidthHalf = RES_WIDTH * 0.5;
viewHeightHalf = RES_HEIGHT * 0.5;
xOffset = 0;

shakeLength = 0;
shakeMagnitude = 0;
shakeRemain = 0;

x = viewWidthHalf;
y = viewHeightHalf;
xTo = viewWidthHalf;
yTo = viewHeightHalf;

if (instance_exists(oPlayer)) {
    y = oPlayer.y - 10;
    yTo = y;
}
