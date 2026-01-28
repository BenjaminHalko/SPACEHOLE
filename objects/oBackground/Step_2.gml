/// @desc Create particles


mask.Update();

/*
with(oMaskEnemy) {
    var _lines = array_length(mask.pointsLine);
    for(var i = 0; i < _lines - 1; i++) {
        var _dist = point_distance(mask.pointsLine[i][0], mask.pointsLine[i][1], mask.pointsLine[i + 1][0], mask.pointsLine[i + 1][1]);
        var _dir = point_direction(mask.pointsLine[i][0], mask.pointsLine[i][1], mask.pointsLine[i + 1][0], mask.pointsLine[i + 1][1]);
        for(var j = 0; j < _dist; j += 10) {
            var _x = mask.x + mask.pointsLine[i][0] + lengthdir_x(j, _dir);
            var _y = mask.y + mask.pointsLine[i][1] + lengthdir_y(j, _dir);
            instance_create_depth(_x, _y, depth - 1, oMaskParticle);
        }
    }
}