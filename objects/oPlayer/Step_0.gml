/// @desc Update Player

if (global.gameOver) {
    exit;
}

// Death
var _maskCollision = place_meeting(x, y, pMask);
with (pMask) {
    if (mask.HasCollision(other.x, other.y)) {
        _maskCollision = true;
        break;
    }
}

death = Approach(death, _maskCollision, _maskCollision ? deathSpd : deathRecovery);
if (death >= 1) {
    global.gameOver = true;
}

if (_maskCollision and y > oDoomZone.mask.y) {
    var _dir = point_direction(0, 0, hsp, vsp);
    var _spd = 0.3;
    hsp = ApproachEase(hsp, lengthdir_x(_spd, _dir), abs(lengthdir_x(1, _dir)), 0.85);
    vsp = ApproachEase(vsp, lengthdir_y(_spd, _dir), abs(lengthdir_y(1, _dir)), 0.85);
}

// Move Camera
if (y - radius < oDoomZone.mask.y) {
    if (swingTarget != noone and swinging) {
        oCamera.yTo = lerp(y, swingTarget.y, 0.5);
    } else {
        oCamera.yTo = y;
    }
    
    vsp = clamp(vsp + (_maskCollision ? grv / 3 : grv), -18, 12);
    hsp = ApproachEase(hsp, 0, 0.01, 0.8);
}

// Jump
jumpTimer--;
if (keyboard_check_pressed(vk_space)) {
    jumpTimer = 10;
}

swinging = swingTarget != noone and keyboard_check(vk_space);

// Movement
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
    hsp = (_xTarget - x);
    vsp = (_yTarget - y);
} else {
    if (swingingPrev) {
        hsp *= 1.5;
        vsp *= 1.5;
    }
    if (x < 0 and hsp < 0)
        hsp = abs(hsp * 0.8);
    else if (x > RES_WIDTH and hsp > 0)
        hsp = -abs(hsp * 0.8);
    
    swingTarget = instance_nearest(x, y, oMaskEnemy);
    if (swingTarget != noone and point_distance(x, y, swingTarget.x, swingTarget.y) > 120) {
        swingTarget = noone;
    }
    
    // Jump off wall (biased upward)
    if (wallContact != noone && jumpTimer) {
        var _jumpX = wallNormalX * (1 - jumpUpBias);
        var _jumpY = lerp(wallNormalY, -1, jumpUpBias);
        var _len = sqrt(_jumpX * _jumpX + _jumpY * _jumpY);
        var _str = jumpStrength;
        if (wallContact.object_index == oFlipper) {
            wallContact.image_angle += 30 * wallContact.image_xscale;
            _str *= 2;
        }
        hsp += (_jumpX / _len) * _str;
        vsp += (_jumpY / _len) * _str;
        
        
    }
    
    // Dash
    PlayerLauncherCollision();
    if (dashTimer > 0) {
        dashTimer--;
        instance_create_depth(x, y, depth + 1, oPlayerDash, {
            image_angle: image_angle
        });
    }
}

x += hsp;
y += vsp;

// Wall Collision
PlayerWallCollision();
PlayerFlipperCollision();

image_angle = ApproachEase(image_angle, -hsp * 15, 10, 0.8);
lightning.Step();

swingingPrev = swinging;
