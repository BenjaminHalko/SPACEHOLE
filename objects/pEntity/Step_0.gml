/// @desc Movement

if (moveSpeed > 0) {
    moveAmount += moveSpeed;
    
    if (moveCircle) {
        var _percent = moveAmount * 360;
        x = xstart + lengthdir_x(xMove, _percent);
        y = ystart + lengthdir_y(yMove, _percent);
    } else {
        var _percent = (cos(moveAmount * pi * 2) + 1) / 2;
        x = xstart + xMove * _percent;
        y = ystart + yMove * _percent;
    }
}
