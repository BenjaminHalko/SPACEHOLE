/// @desc Setup Entity

flipped = (RoomLoader.__xScale == -1);
if (flipped) {
    xMove = RES_WIDTH - xMove;
}

// Link objects
moveAmount = moveOffset + 0.5;
moveSpeed = 1 / 60 / moveSpeed;

