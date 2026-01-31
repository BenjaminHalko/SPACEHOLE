/// @desc Update Camera

//Update Object Position
x += (xTo - x) / 12;
y += (yTo - y) / 8;

//Screenshake
x += random_range(-shakeRemain,shakeRemain);
y += random_range(-shakeRemain,shakeRemain);

shakeRemain = max(0, shakeRemain - ((1/shakeLength) * shakeMagnitude));

camera_set_view_pos(cam,round(x) - viewWidthHalf,round(y) - viewHeightHalf);