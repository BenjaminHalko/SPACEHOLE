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
        // Triangle in LOCAL sprite space (before any transforms)
        var _w = sprite_width - 12;
        var _hh = sprite_height / 2;

        // Local vertices: A(0,hh), B(w,hh), C(0,-hh)
        // Transform each vertex to WORLD space
        var _rad = degtorad(image_angle);
        var _cos = cos(_rad);
        var _sin = sin(_rad);
        var _xs = image_xscale;

        // World vertex A (origin corner, right angle)
        var _ax = x + 0 * _xs * _cos - _hh * _sin;
        var _ay = y + 0 * _xs * _sin + _hh * _cos;

        // World vertex B (far corner of bottom edge)
        var _bx = x + _w * _xs * _cos - _hh * _sin;
        var _by = y + _w * _xs * _sin + _hh * _cos;

        // World vertex C (top of origin side)
        var _cx = x + 0 * _xs * _cos - (-_hh) * _sin;
        var _cy = y + 0 * _xs * _sin + (-_hh) * _cos;

        // Player position and radius
        var _playerX = other.x;
        var _playerY = other.y;
        var _radius = other.radius;

        // Find closest point on triangle perimeter (in world space)
        var _closestX, _closestY;
        var _minDistSq = infinity;

        // Edge A-B (bottom edge)
        var _abx = _bx - _ax;
        var _aby = _by - _ay;
        var _abLenSq = _abx * _abx + _aby * _aby;
        var _t = clamp(((_playerX - _ax) * _abx + (_playerY - _ay) * _aby) / _abLenSq, 0, 1);
        var _px = _ax + _t * _abx;
        var _py = _ay + _t * _aby;
        var _distSq = sqr(_playerX - _px) + sqr(_playerY - _py);
        if (_distSq < _minDistSq) {
            _minDistSq = _distSq;
            _closestX = _px;
            _closestY = _py;
        }

        // Edge C-A (left/origin edge)
        var _cax = _ax - _cx;
        var _cay = _ay - _cy;
        var _caLenSq = _cax * _cax + _cay * _cay;
        _t = clamp(((_playerX - _cx) * _cax + (_playerY - _cy) * _cay) / _caLenSq, 0, 1);
        _px = _cx + _t * _cax;
        _py = _cy + _t * _cay;
        _distSq = sqr(_playerX - _px) + sqr(_playerY - _py);
        if (_distSq < _minDistSq) {
            _minDistSq = _distSq;
            _closestX = _px;
            _closestY = _py;
        }

        // Edge B-C (hypotenuse)
        var _bcx = _cx - _bx;
        var _bcy = _cy - _by;
        var _bcLenSq = _bcx * _bcx + _bcy * _bcy;
        _t = clamp(((_playerX - _bx) * _bcx + (_playerY - _by) * _bcy) / _bcLenSq, 0, 1);
        _px = _bx + _t * _bcx;
        _py = _by + _t * _bcy;
        _distSq = sqr(_playerX - _px) + sqr(_playerY - _py);
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

        // Push normal (world space, from closest point toward player)
        var _normX, _normY;
        if (_dist > 0.001) {
            _normX = (_playerX - _closestX) / _dist;
            _normY = (_playerY - _closestY) / _dist;
        } else {
            // Fallback: use perpendicular to hypotenuse pointing outward
            var _bcLen = sqrt(_bcLenSq);
            // Perpendicular to B->C, choosing direction away from A
            _normX = _bcy / _bcLen;
            _normY = -_bcx / _bcLen;
            // Check if this points toward or away from A, flip if needed
            var _toAx = _ax - _bx;
            var _toAy = _ay - _by;
            if (_normX * _toAx + _normY * _toAy > 0) {
                _normX = -_normX;
                _normY = -_normY;
            }
        }

        // Check mask at closest point
        if (PointIsMasked(_closestX, _closestY)) {
            continue;
        }

        // Push player out
        other.x += _normX * _overlap;
        other.y += _normY * _overlap;

        // Store wall contact info
        other.wallContact = true;
        other.wallNormalX = _normX * 2;
        other.wallNormalY = _normY * 2;

        // Reflect velocity
        var _dot = other.hsp * _normX + other.vsp * _normY;
        if (_dot < 0) {
            other.hsp -= _normX * _dot;
            other.vsp -= _normY * _dot;
        }

        // Apply friction
        var _tangentX = -_normY;
        var _tangentY = _normX;
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


