/// @desc Setup Entity

flipped = (RoomLoader.__xScale == -1);
if (flipped) {
    xMove = RES_WIDTH - xMove;
}

// Link objects
moveAmount = moveOffset + 0.5;
moveSpeed = 1 / 60 / moveSpeed;
linkedObjects = [];
if (moveSpeed >= 0 and moveStick) {
    call_later(1, time_source_units_frames, function() {
        var _list = ds_list_create();
        var _num = instance_place_list(x, y, pEntity, _list, false);
        for (var i = 0; i < _num; i++) {
            array_push(linkedObjects, [_list[| i].id, _list[| i].x - x, _list[| i].y - y]);
        }
        ds_list_destroy(_list);
    });
}

MoveLinkedObjects = function() {
    var _len = array_length(linkedObjects);
    for(var i = 0; i < _len; i++) {
        var _obj = linkedObjects[i];
        with(_obj[0]) {
            x = other.x + _obj[1];
            y = other.y + _obj[2];
        }
    }
}
