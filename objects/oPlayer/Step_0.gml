/// @desc Update Player

// Particles
if (particle-- <= 0 and global.gameState != GameState.DEATH and death < 0.98) {
    particle = 5;
    var _p = instance_create_depth(x + lengthdir_x(10, image_angle-90),y + lengthdir_y(10, image_angle-90),depth+1, oPlayerSpeedBoost);
    _p.image_blend = c_lime;
    _p.speed = 2;
    _p.direction = image_angle - 90;
    _p.image_angle = image_angle + 90;
}


if (global.gameState == GameState.END) {
    y -= 10;
    x = ApproachEase(x, RES_WIDTH / 2, 5, 0.8)
    oCamera.yTo = y - 10;
    image_angle = ApproachEase(image_angle, Wave(-16, 16, 1, 0), 7, 0.8);
}

if (global.gameState != GameState.NORMAL) {
    exit;
}

global.score++;
if (global.gameScore != -1) {
    global.gameScore++;
}

var _end = true;
with(pEntity) {
    if (y < oCamera.y + RES_WIDTH / 2 or y < other.y) {
        _end = false;
        break;
    }
}

if (_end) {
    FinishLevel();
    exit;
}

// Death
var _reallyDead = false;
var _maskCollision = place_meeting(x, y, pMask);
with (pMask) {
    if (mask.HasCollision(other.x, other.y)) {
        _maskCollision = true;
        if (object_index == oDoomZone) _reallyDead = true;
        break;
    }
}

death = Approach(death, _maskCollision, (_maskCollision ? deathSpd : deathRecovery) * (1 + _reallyDead * 2));
if (death >= 1) {
    global.gameState = GameState.DEATH;
    if (_reallyDead) {
        transition(room);
    } else {
        call_later(1 - _reallyDead * 0.8, time_source_units_seconds, function() {
            transition(room);
        });
    }
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
        oCamera.yTo = lerp(y, swingTarget.y, 0.5) - 30;
    } else {
        oCamera.yTo = y - 10;
    }
    
    vsp = clamp(vsp + (_maskCollision ? grv / 6 : grv), -18, 12);
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
    
    ropeLength = 50 + 50 * abs(swingTarget.image_xscale);

    // On first frame of swinging, convert linear velocity to angular velocity
    if (!swingingPrev) {
        // Calculate tangential component of velocity
        // Tangent direction is perpendicular to rope (dir + 90)
        var _tangentDir = _dir + 90;
        var _tangentSpeed = dot_product(hsp, vsp, lengthdir_x(1, _tangentDir), lengthdir_y(1, _tangentDir));
        // Convert to angular velocity (degrees per frame)
        swingSpeed = (_tangentSpeed / max(_dist, 1)) * (180 / pi) * 2;

        swingSpeed = clamp(swingSpeed, -4, 4);
    }

    // Apply gravity as angular acceleration
    // sin(angle from vertical) determines how much gravity affects swing
    // _dir is from pivot's perspective, so we use cos(_dir) for horizontal offset
    var _gravityAccel = -(grv / max(ropeLength, 1)) * cos(degtorad(_dir)) * (180 / pi) * 0.8;
    swingSpeed += _gravityAccel;

    // Small amount of damping for feel
    //swingSpeed *= 0.995;
    
    //swingSpeed = ApproachEase(swingSpeed, 4 * sign(swingSpeed), 1, 0.8);

    _dir += swingSpeed;

    // Maintain rope length (slight elasticity)
    swingTarget.targetSize = ApproachEase(swingTarget.targetSize, 2 + 3 * abs(swingTarget.image_xscale), 6, 0.8);
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
    if (x < 0 and hsp < 2)
        hsp = max(2, abs(hsp));
    else if (x > RES_WIDTH and hsp > -2)
        hsp = min(-2, -abs(hsp));
    
    swingTarget = instance_nearest(x, y, oPlanet);
    if (swingTarget != noone and point_distance(x, y, swingTarget.x, swingTarget.y) > 90 + 30 * abs(swingTarget.image_xscale)) {
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
