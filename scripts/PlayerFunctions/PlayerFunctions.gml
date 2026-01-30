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
        var _rad = degtorad(-image_angle);
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


function PlayerFlipperCollision() {
    with (oFlipper) {
        // Triangle dimensions - scale width by xscale (can be negative)
        var _w = (sprite_width - 12) * image_xscale;
        var _hh = sprite_height / 2;

        // Triangle vertices in SCALED local space:
        // A (0, hh)  = origin corner (right angle vertex)
        // B (w, hh)  = far corner (w is negative if flipped)
        // C (0, -hh) = top of origin side
        var _ax = 0, _ay = _hh;
        var _bx = _w, _by = _hh;
        var _cx = 0, _cy = -_hh;

        // Transform player to flipper's rotated local space (no scale division)
        var _rad = degtorad(-image_angle);
        var _cos = cos(_rad);
        var _sin = sin(_rad);

        var _dx = other.x - x;
        var _dy = other.y - y;

        var _localX = _dx * _cos + _dy * _sin;
        var _localY = -_dx * _sin + _dy * _cos;

        var _radius = other.radius;

        // Find closest point on triangle perimeter
        var _closestX, _closestY;
        var _minDistSq = infinity;

        // Edge A-B (bottom, horizontal - but B can be left or right of A)
        var _px = clamp(_localX, min(0, _w), max(0, _w));
        var _py = _hh;
        var _distSq = sqr(_localX - _px) + sqr(_localY - _py);
        if (_distSq < _minDistSq) {
            _minDistSq = _distSq;
            _closestX = _px;
            _closestY = _py;
        }

        // Edge C-A (vertical at x=0)
        _px = 0;
        _py = clamp(_localY, -_hh, _hh);
        _distSq = sqr(_localX - _px) + sqr(_localY - _py);
        if (_distSq < _minDistSq) {
            _minDistSq = _distSq;
            _closestX = _px;
            _closestY = _py;
        }

        // Edge B-C (hypotenuse)
        var _bcx = _cx - _bx;  // 0 - _w = -_w
        var _bcy = _cy - _by;  // -_hh - _hh = -sprite_height
        var _bcLenSq = _bcx * _bcx + _bcy * _bcy;
        var _t = clamp(((_localX - _bx) * _bcx + (_localY - _by) * _bcy) / _bcLenSq, 0, 1);
        _px = _bx + _t * _bcx;
        _py = _by + _t * _bcy;
        _distSq = sqr(_localX - _px) + sqr(_localY - _py);
        if (_distSq < _minDistSq) {
            _minDistSq = _distSq;
            _closestX = _px;
            _closestY = _py;
        }

        // Check collision
        if (_minDistSq >= _radius * _radius) {
            continue;
        }

        var _dist = sqrt(_minDistSq);
        var _overlap = _radius - _dist;

        // Push normal (local space, from closest point toward player)
        var _normX, _normY;
        if (_dist > 0.001) {
            _normX = (_localX - _closestX) / _dist;
            _normY = (_localY - _closestY) / _dist;
        } else {
            // Center on edge - use hypotenuse outward normal
            // Perpendicular pointing away from triangle interior
            var _bcLen = sqrt(_bcLenSq);
            _normX = -_bcy / _bcLen * sign(image_xscale);
            _normY = _bcx / _bcLen * sign(image_xscale);
        }

        // Transform closest point to world space for mask check
        var _worldClosestX = x + _closestX * _cos - _closestY * _sin;
        var _worldClosestY = y + _closestX * _sin + _closestY * _cos;

        if (PointIsMasked(_worldClosestX, _worldClosestY)) {
            continue;
        }

        // Transform normal back to world space
        var _worldNormX = _normX * _cos - _normY * _sin;
        var _worldNormY = _normX * _sin + _normY * _cos;

        // Push player out
        other.x += _worldNormX * _overlap;
        other.y += _worldNormY * _overlap;

        // Store wall contact info
        other.wallContact = true;
        other.wallNormalX = _worldNormX * 2;
        other.wallNormalY = _worldNormY * 2;

        // Reflect velocity
        var _dot = other.hsp * _worldNormX + other.vsp * _worldNormY;
        if (_dot < 0) {
            other.hsp -= _worldNormX * _dot;
            other.vsp -= _worldNormY * _dot;
        }

        // Apply friction
        var _tangentX = -_worldNormY;
        var _tangentY = _worldNormX;
        var _tangentDot = other.hsp * _tangentX + other.vsp * _tangentY;
        other.hsp -= _tangentX * _tangentDot * (1 - other.flipperFriction);
        other.vsp -= _tangentY * _tangentDot * (1 - other.flipperFriction);
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

            // Launch player in direction + 90
            var _launchDir = image_angle + 90;
            var _launchSpeed = 14;

            other.hsp = lengthdir_x(_launchSpeed, _launchDir);
            other.vsp = lengthdir_y(_launchSpeed, _launchDir);
            other.dashTimer = 10;
        }
    }
}


