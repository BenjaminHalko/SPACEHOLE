Input();

swinging = keyboard_check(vk_space);

if (swingTarget != noone and swinging) {
    oCamera.xTo = lerp(x, swingTarget.x, 0.5);
    oCamera.yTo = lerp(y, swingTarget.y, 0.5);
} else {
    oCamera.xTo = x;
    oCamera.yTo = y;
}


// Move
var _maskCollision = false;

with (oMaskEnemy) {
    if (point_distance(x, y, other.x, other.y) < mask.size * mask.BaseRadius) {
        _maskCollision = true;
        break;
    }
}


if (y - radius < oBackground.mask.y) {
    if (!_maskCollision) {
        vsp = clamp(vsp + grv, -18, 12);
    }
} else {
    hsp = ApproachEase(hsp, 0, 0.1, 0.8);
    vsp = ApproachEase(vsp, 0.2, 10, 0.5);
}



if (swinging) {
    var _dist = point_distance(x, y, swingTarget.x, swingTarget.y);
    var _dir = point_direction(swingTarget.x, swingTarget.y, x, y);

    // On first frame of swinging, convert linear velocity to angular velocity
    if (!swingingPrev) {
        // Calculate tangential component of velocity
        // Tangent direction is perpendicular to rope (dir + 90)
        var _tangentDir = _dir + 90;
        var _tangentSpeed = dot_product(hsp, vsp, lengthdir_x(1, _tangentDir), lengthdir_y(1, _tangentDir));
        // Convert to angular velocity (degrees per frame)
        swingSpeed = (_tangentSpeed / max(_dist, 1)) * (180 / pi);
        
        swingSpeed = clamp(swingSpeed, -4, 4);
    }

    // Apply gravity as angular acceleration
    // sin(angle from vertical) determines how much gravity affects swing
    // _dir is from pivot's perspective, so we use cos(_dir) for horizontal offset
    var _gravityAccel = -(grv / max(ropeLength, 1)) * cos(degtorad(_dir)) * (180 / pi);
    swingSpeed += _gravityAccel;

    // Small amount of damping for feel
    //swingSpeed *= 0.995;
    
    //swingSpeed = ApproachEase(swingSpeed, 4 * sign(swingSpeed), 1, 0.8);

    _dir += swingSpeed;

    // Maintain rope length (slight elasticity)
    swingTarget.targetSize = ApproachEase(swingTarget.targetSize, 4, 1.5, 0.8);
    _dist = lerp(_dist, ropeLength, 0.1);

    var _xTarget = swingTarget.x + lengthdir_x(_dist, _dir);
    var _yTarget = swingTarget.y + lengthdir_y(_dist, _dir);
    hsp = (_xTarget - x) * 1.4;
    vsp = (_yTarget - y) * 1.4;
    x = _xTarget;
    y = _yTarget;
} else {
    if (x < 0)
        hsp = abs(hsp);
    else if (x > RES_WIDTH)
        hsp = -abs(hsp);
    
    swingTarget = instance_nearest(x, y, oMaskEnemy);
    
    var _move = keyRight - keyLeft;
    hsp = ApproachEase(hsp, _move * moveSpd, 0.02, 0.85);
    hsp = clamp(hsp, -5, 5);
    
    x += hsp;
    y += vsp;
}

image_angle -= hsp * 3;
lightning.Step();

swingingPrev = swinging;
