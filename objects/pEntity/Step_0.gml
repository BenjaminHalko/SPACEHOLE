/// @desc Movement

if (moveSpeed > 0) {
    moveAmount += moveSpeed;
    var _percent = (cos(moveAmount * pi * 2) + 1) / 2;
    x = xstart + xMove * _percent;
    y = ystart + yMove * _percent;
    MoveLinkedObjects();
}
