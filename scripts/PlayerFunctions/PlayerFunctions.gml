/// @func PointIsMasked(_x, _y)
/// @desc Check if a world-space point is inside any mask
function PointIsMasked(_x, _y) {
    with (oPlayer) {
        if (place_meeting(_x, _y, pMask)) {
            return true;
        }
    }
    with (pMask) {
        if (mask.HasCollision(_x, _y)) {
            return true;
        }
    }
    return false;
}

/// @func PlayerWallCollision()
/// @desc Handles circle vs rotated rectangle collision for player against oWall instances
function PlayerWallCollision() {
    wallContact = false;

    with (oWall) {
        // Rectangle half-dimensions (sprite_width/height include scale)
        var _hw = sprite_width / 2;
        var _hh = sprite_height / 2;

        // Wall center IS (x, y) since sprite origin is centered
        // Transform player to wall's local space (rotate around wall center)
        var _angle = -image_angle;
        var _rad = degtorad(_angle);
        var _cos = cos(_rad);
        var _sin = sin(_rad);

        var _dx = other.x - x;
        var _dy = other.y - y;

        // Rotate player position into wall's local space
        var _localX = _dx * _cos + _dy * _sin;
        var _localY = -_dx * _sin + _dy * _cos;

        // Find closest point on rectangle (in local space)
        var _closestX = clamp(_localX, -_hw, _hw);
        var _closestY = clamp(_localY, -_hh, _hh);

        // Vector from closest point to circle center
        var _diffX = _localX - _closestX;
        var _diffY = _localY - _closestY;
        var _distSq = _diffX * _diffX + _diffY * _diffY;
        var _radius = other.radius;

        if (_distSq < _radius * _radius) {
            // Check if any point on player perimeter is inside wall AND not masked
            var _samples = 12;
            var _hasExposedCollision = false;

            for (var i = 0; i < _samples; i++) {
                var _angle = i / _samples * 360;
                // Sample point on player's circumference (world space)
                var _sampleX = other.x + lengthdir_x(_radius, _angle);
                var _sampleY = other.y + lengthdir_y(_radius, _angle);

                // Transform to wall's local space
                var _sdx = _sampleX - x;
                var _sdy = _sampleY - y;
                var _sLocalX = _sdx * _cos + _sdy * _sin;
                var _sLocalY = -_sdx * _sin + _sdy * _cos;

                // Check if inside wall rectangle
                if (abs(_sLocalX) <= _hw && abs(_sLocalY) <= _hh) {
                    // Inside wall - check if NOT masked
                    if (!PointIsMasked(_sampleX, _sampleY)) {
                        _hasExposedCollision = true;
                        break;
                    }
                }
            }

            if (!_hasExposedCollision) {
                continue;  // Fully masked - skip collision
            }

            var _dist = sqrt(_distSq);
            var _overlap = _radius - _dist;

            // Calculate push direction (local space)
            var _normX, _normY;
            if (_dist > 0.001) {
                _normX = _diffX / _dist;
                _normY = _diffY / _dist;
            } else {
                // Circle center inside rectangle - push toward nearest edge
                var _edgeX = _hw - abs(_localX);
                var _edgeY = _hh - abs(_localY);
                if (_edgeX < _edgeY) {
                    _normX = (_localX >= 0) ? 1 : -1;
                    _normY = 0;
                    _overlap = _edgeX + _radius;
                } else {
                    _normX = 0;
                    _normY = (_localY >= 0) ? 1 : -1;
                    _overlap = _edgeY + _radius;
                }
            }

            // Transform normal back to world space
            var _worldNormX = _normX * _cos - _normY * _sin;
            var _worldNormY = _normX * _sin + _normY * _cos;

            // Semi-solid: only collide when landing on top (normal points up, player moving down)
            if (object_index == oSemiSolid) {
                if (_worldNormY >= 0 || other.vsp < 0) {
                    continue;
                }
            }

            // Push player out
            other.x += _worldNormX * _overlap;
            other.y += _worldNormY * _overlap;

            // Store wall contact info for jumping
            other.wallContact = true;
            other.wallNormalX = _worldNormX;
            other.wallNormalY = _worldNormY;

            // Reflect velocity (remove component going into wall)
            var _dot = other.hsp * _worldNormX + other.vsp * _worldNormY;
            if (_dot < 0) {
                // Restitution: 1.0 = no bounce, 2.0 = full reflect
                other.hsp -= _worldNormX * _dot * 1.0;
                other.vsp -= _worldNormY * _dot * 1.0;
            }

            // Friction: reduce tangential (sliding) velocity
            var _tangentX = -_worldNormY;
            var _tangentY = _worldNormX;
            var _tangentDot = other.hsp * _tangentX + other.vsp * _tangentY;
            other.hsp -= _tangentX * _tangentDot * (1 - other.wallFriction);
            other.vsp -= _tangentY * _tangentDot * (1 - other.wallFriction);
        }
    }
}

/// @func PlayerFlipperCollision()
/// @desc Handles circle vs line collision for player against oFlipper instances (semi-solid)
function PlayerFlipperCollision() {
    with (oFlipper) {
        // Line endpoints in local space (base sprite coords relative to origin 12,12)
        // Triangle starts 6px from left, origin is 12px from left
        // A = top-left of triangle, B = bottom-right
        var _ax = -6;   // 6 - 12 = -6
        var _ay = -12;  // 0 - 12 = -12 (top)
        var _bx = 52;   // 64 - 12 = 52 (right edge)
        var _by = 12;   // 24 - 12 = 12 (bottom)

        // Apply image_xscale (flip horizontally if negative)
        var _xscale = image_xscale;
        _ax *= _xscale;
        _bx *= _xscale;

        // Transform to world space (rotate by image_angle, translate by position)
        var _rad = degtorad(image_angle);
        var _cos = cos(_rad);
        var _sin = sin(_rad);

        var _worldAx = x + _ax * _cos - _ay * _sin;
        var _worldAy = y + _ax * _sin + _ay * _cos;
        var _worldBx = x + _bx * _cos - _by * _sin;
        var _worldBy = y + _bx * _sin + _by * _cos;

        // Circle-line segment collision
        // Find closest point on segment to player center
        var _dx = _worldBx - _worldAx;
        var _dy = _worldBy - _worldAy;
        var _lenSq = _dx * _dx + _dy * _dy;

        var _t = clamp((
            (other.x - _worldAx) * _dx + (other.y - _worldAy) * _dy
        ) / _lenSq, 0, 1);

        var _closestX = _worldAx + _t * _dx;
        var _closestY = _worldAy + _t * _dy;

        var _distX = other.x - _closestX;
        var _distY = other.y - _closestY;
        var _distSq = _distX * _distX + _distY * _distY;

        if (_distSq < other.radius * other.radius) {
            // Calculate line normal (perpendicular, pointing "up" from surface)
            var _lineLen = sqrt(_lenSq);
            var _normX = -_dy / _lineLen;  // Perpendicular to line
            var _normY = _dx / _lineLen;

            // Ensure normal points away from triangle's filled area (upward)
            // For standard orientation, normal should point up-left
            if (_normY > 0) {
                _normX = -_normX;
                _normY = -_normY;
            }

            // Semi-solid check: only collide when player moving toward surface
            var _velDot = other.hsp * _normX + other.vsp * _normY;
            if (_velDot >= 0) continue;  // Moving away, skip

            // Mask check (sample points)
            var _hasExposedCollision = false;
            var _samples = 8;
            for (var i = 0; i < _samples; i++) {
                var _sampleAngle = i / _samples * 360;
                var _sampleX = other.x + lengthdir_x(other.radius, _sampleAngle);
                var _sampleY = other.y + lengthdir_y(other.radius, _sampleAngle);
                // Check if collision point is not masked
                if (!PointIsMasked(_closestX, _closestY)) {
                    _hasExposedCollision = true;
                    break;
                }
            }
            if (!_hasExposedCollision) continue;

            // Push player out
            var _dist = sqrt(_distSq);
            var _overlap = other.radius - _dist;
            other.x += _normX * _overlap;
            other.y += _normY * _overlap;

            // Wall contact info
            other.wallContact = true;
            other.wallNormalX = _normX;
            other.wallNormalY = _normY;

            // Remove velocity into surface
            other.hsp -= _normX * _velDot;
            other.vsp -= _normY * _velDot;

            // Apply friction
            var _tangentX = -_normY;
            var _tangentY = _normX;
            var _tangentDot = other.hsp * _tangentX + other.vsp * _tangentY;
            other.hsp -= _tangentX * _tangentDot * (1 - other.wallFriction);
            other.vsp -= _tangentY * _tangentDot * (1 - other.wallFriction);
        }
    }
}

function PlayerLauncherCollision() {
    with (oLauncher) {
        // Check circle vs rectangle overlap
        var _hw = sprite_width / 2;
        var _hh = sprite_height / 2;

        var _rad = degtorad(-image_angle);
        var _cos = cos(_rad);
        var _sin = sin(_rad);

        var _dx = other.x - x;
        var _dy = other.y - y;

        var _localX = _dx * _cos + _dy * _sin;
        var _localY = -_dx * _sin + _dy * _cos;

        var _closestX = clamp(_localX, -_hw, _hw);
        var _closestY = clamp(_localY, -_hh, _hh);

        var _diffX = _localX - _closestX;
        var _diffY = _localY - _closestY;
        var _distSq = _diffX * _diffX + _diffY * _diffY;

        if (_distSq < other.radius * other.radius) {
            // Check if any point on player perimeter is inside launcher AND not masked
            var _samples = 12;
            var _hasExposedCollision = false;

            for (var i = 0; i < _samples; i++) {
                var _angle = i / _samples * 360;
                // Sample point on player's circumference (world space)
                var _sampleX = other.x + lengthdir_x(other.radius, _angle);
                var _sampleY = other.y + lengthdir_y(other.radius, _angle);

                // Transform to launcher's local space
                var _sdx = _sampleX - x;
                var _sdy = _sampleY - y;
                var _sLocalX = _sdx * _cos + _sdy * _sin;
                var _sLocalY = -_sdx * _sin + _sdy * _cos;

                // Check if inside launcher rectangle
                if (abs(_sLocalX) <= _hw && abs(_sLocalY) <= _hh) {
                    // Inside launcher - check if NOT masked
                    if (!PointIsMasked(_sampleX, _sampleY)) {
                        _hasExposedCollision = true;
                        break;
                    }
                }
            }

            if (!_hasExposedCollision) {
                continue;  // Fully masked - skip collision
            }
            
            if (object_index == oKey) {
                if (!active) {
                    active = true;
                    with (oDoor) {
                        if (doorID == other.doorID) {
                            active = true;
                        }
                    }
                    ScreenShake(2, 30);
                }
            } else {
                // Launch player in direction + 90
                var _launchDir = image_angle + 90;
                var _launchSpeed = 14;
                
                other.hsp = lengthdir_x(_launchSpeed, _launchDir);
                other.vsp = lengthdir_y(_launchSpeed, _launchDir);
                other.dashTimer = 10;
            }
        }
    }
}


