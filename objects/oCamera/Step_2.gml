/// @desc Update Camera

if (y >= oDoomZone.mask.y - viewHeightHalf + 60) {
    //yTo = min(yTo, y);
}

//Update Object Position
x += (xTo - x) / 12;
y += (yTo - y) / 4;

//Keep Camera center inside room
x = clamp(x, viewWidthHalf, room_width-viewWidthHalf);
//y = clamp(y, viewHeightHalf, room_height-viewHeightHalf);

//Screenshake
x += random_range(-shakeRemain,shakeRemain);
y += random_range(-shakeRemain,shakeRemain);

shakeRemain = max(0, shakeRemain - ((1/shakeLength) * shakeMagnitude));

camera_set_view_pos(cam,round(x) - viewWidthHalf,round(y) - viewHeightHalf);