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
            // Launch player in direction + 90
            var _launchDir = image_angle + 90;
            var _launchSpeed = 12;

            other.hsp = lengthdir_x(_launchSpeed, _launchDir);
            other.vsp = lengthdir_y(_launchSpeed, _launchDir);
            other.dashTimer = 10;
        }
    }
}
