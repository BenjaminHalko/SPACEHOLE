function __MaskParent() constructor {
    x = 0;
    y = 0;
    size = 0;
    points = [];
    pointsLine = [];
    pointOffsets = [];

    Draw = function() {
        var _ptsLen = array_length(points);

        draw_primitive_begin(pr_trianglestrip);
        for (var i = 0; i < _ptsLen; i++) {
            draw_vertex(x + points[i][0], y + points[i][1]);
        }
        draw_primitive_end();
    }
    
    static DrawOutline = function() {
        var _ptsLen = array_length(pointsLine);
        
        draw_primitive_begin(pr_linelist);
        for (var i = 0; i < _ptsLen; i++) {
            draw_vertex(x + pointsLine[i][0], y + pointsLine[i][1]);
        }
        draw_primitive_end();
    }
    
    /// @param {real} index
    /// @param {real} x
    /// @param {real} y
    /// @param {real} targetSpd
    static ApproachPoint = function(_index, _x, _y, _targetSpd) {
        var _currentX = points[_index][0];
        var _currentY = points[_index][1];
        
        var _dir = point_direction(_currentX, _currentY, _x, _y);
        var _dist = point_distance(_currentX, _currentY, _x, _y);
        
        var _move = ApproachEase(0, _dist, _targetSpd, 0.8);
        
        points[_index][0] += lengthdir_x(_move, _dir);
        points[_index][1] += lengthdir_y(_move, _dir);
    }
    
    /// @param {real} index
    /// @param {real} x
    /// @param {real} y
    static SetPoint = function(_index, _x, _y) {
        points[_index][0] = _x;
        points[_index][1] = _y;
    }
}

function MaskBasicCircle() : __MaskParent() constructor {
    static BaseRadius = 32;
    static Sides = 70;

    repeat(Sides) {
        array_push(points, [0, 0], [0, 0], [0, 0]);
        var _len = array_length(points);
        array_push(pointsLine, points[_len - 2], points[_len - 1]);
        array_push(pointOffsets, [0, 0]);
    }

    static HasCollision = function(_x, _y) {
        return point_distance(_x, _y, x, y) < BaseRadius * size;
    }

    DrawColoured = function() {
        // Draw triangles with vertex colors: center dark, edges glowing
        draw_primitive_begin(pr_trianglelist);
        for (var i = 0; i < Sides; i++) {
            var _index = i * 3;
            // Center vertex (dark)
            draw_vertex_colour(x + points[_index][0], y + points[_index][1], centerColor, centerAlpha);
            // Edge vertex 1 (glow)
            draw_vertex_colour(x + points[_index + 1][0], y + points[_index + 1][1], edgeColor, edgeAlpha);
            // Edge vertex 2 (glow)
            draw_vertex_colour(x + points[_index + 2][0], y + points[_index + 2][1], edgeColor, edgeAlpha);
        }
        draw_primitive_end();
    }
    
    static UpdateOffsets = function() {
        var _pointOffsetLen = array_length(pointOffsets);
        for(var i = 0; i < _pointOffsetLen; i++) {
            if (irandom(5) != 0) continue;
            var _angle = i / _pointOffsetLen * 360 + random_range(-10, 10);
            var _dist = random(BaseRadius * size / 6);
            pointOffsets[i][0] = lengthdir_x(_dist, _angle);
            pointOffsets[i][1] = lengthdir_y(_dist, _angle);
        }
    }
    
    static Update = function() {
        for (var i = 0; i < Sides; i++) {
            var _index = i * 3;
            
            SetPoint(_index, 0, 0);
            
            ApproachPoint(_index + 1,
                lengthdir_x(BaseRadius * size, i / Sides * 360) + pointOffsets[i][0],
                lengthdir_y(BaseRadius * size, i / Sides * 360) + pointOffsets[i][1],
                10);
            
            ApproachPoint(_index + 2,
                lengthdir_x(BaseRadius * size, (i + 1) / Sides * 360) + pointOffsets[Wrap(i + 1, 0, Sides-1)][0],
                lengthdir_y(BaseRadius * size, (i + 1) / Sides * 360) + pointOffsets[Wrap(i + 1, 0, Sides-1)][1],
                10);
        }
    }
}

function MaskBasicRectangle() : __MaskParent() constructor {
    static Sides = 70;

    // 4 corner points relative to center: top-left, top-right, bottom-right, bottom-left
    corners = [
        [-24, -16],
        [24, -16],
        [24, 16],
        [-24, 16]
    ];

    repeat(Sides) {
        array_push(points, [0, 0], [0, 0], [0, 0]);
        var _len = array_length(points);
        array_push(pointsLine, points[_len - 2], points[_len - 1]);
        array_push(pointOffsets, [0, 0]);
    }

    /// @param {real} x1 Top-left x
    /// @param {real} y1 Top-left y
    /// @param {real} x2 Top-right x
    /// @param {real} y2 Top-right y
    /// @param {real} x3 Bottom-right x
    /// @param {real} y3 Bottom-right y
    /// @param {real} x4 Bottom-left x
    /// @param {real} y4 Bottom-left y
    static SetCorners = function(_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4) {
        corners[0] = [_x1, _y1];
        corners[1] = [_x2, _y2];
        corners[2] = [_x3, _y3];
        corners[3] = [_x4, _y4];
    }
    
    static SetSize = function(_width, _height, _rotation) {
        var _dir = point_direction(0, 0, _width / 2, -_height / 2);
        var _dist = point_distance(0, 0, _width / 2, _height / 2);
        corners[0] = [lengthdir_x(_dist, 180 - _dir + _rotation), lengthdir_y(_dist, 180 - _dir + _rotation)];
        corners[1] = [lengthdir_x(_dist, _dir + _rotation), lengthdir_y(_dist, _dir + _rotation)];
        corners[2] = [lengthdir_x(_dist, -_dir + _rotation), lengthdir_y(_dist, -_dir + _rotation)];
        corners[3] = [lengthdir_x(_dist, 180 + _dir + _rotation), lengthdir_y(_dist, 180 + _dir + _rotation)];
    }

    static HasCollision = function(_x, _y) {
        var _tc = corners;
        var _px = _x - x;
        var _py = _y - y;

        // Point-in-quadrilateral using cross product method
        for (var i = 0; i < 4; i++) {
            var _next = (i + 1) mod 4;
            var _edgeX = _tc[_next][0] - _tc[i][0];
            var _edgeY = _tc[_next][1] - _tc[i][1];
            var _toPointX = _px - _tc[i][0];
            var _toPointY = _py - _tc[i][1];
            var _cross = _edgeX * _toPointY - _edgeY * _toPointX;
            if (_cross > 0) return false;
        }
        return true;
    }

    /// @param {real} t Value from 0 to 1 representing position around perimeter
    /// @returns {array} [x, y] position on rectangle edge
    static GetPerimeterPoint = function(_t) {
        var _tc = corners;

        // Calculate edge lengths
        var _lengths = [];
        var _totalLen = 0;
        for (var i = 0; i < 4; i++) {
            var _next = (i + 1) mod 4;
            var _len = point_distance(_tc[i][0], _tc[i][1], _tc[_next][0], _tc[_next][1]);
            array_push(_lengths, _len);
            _totalLen += _len;
        }

        var _dist = _t * _totalLen;
        var _cumulative = 0;

        for (var i = 0; i < 4; i++) {
            if (_dist <= _cumulative + _lengths[i]) {
                var _edgeT = (_dist - _cumulative) / _lengths[i];
                var _next = (i + 1) mod 4;
                return [
                    lerp(_tc[i][0], _tc[_next][0], _edgeT),
                    lerp(_tc[i][1], _tc[_next][1], _edgeT)
                ];
            }
            _cumulative += _lengths[i];
        }

        return [_tc[0][0], _tc[0][1]];
    }

    static UpdateOffsets = function() {
        var _pointOffsetLen = array_length(pointOffsets);
        for(var i = 0; i < _pointOffsetLen; i++) {
            if (irandom(5) != 0) continue;
            var _perimPt = GetPerimeterPoint(i / _pointOffsetLen);
            var _angle = point_direction(0, 0, _perimPt[0], _perimPt[1]) + random_range(-20, 20);
            var _dist = random(8);
            pointOffsets[i][0] = lengthdir_x(_dist, _angle);
            pointOffsets[i][1] = lengthdir_y(_dist, _angle);
        }
    }

    static Update = function() {
        for (var i = 0; i < Sides; i++) {
            var _index = i * 3;

            SetPoint(_index, 0, 0);

            var _pt1 = GetPerimeterPoint(i / Sides);
            var _pt2 = GetPerimeterPoint((i + 1) / Sides);

            ApproachPoint(_index + 1,
                _pt1[0] + pointOffsets[i][0],
                _pt1[1] + pointOffsets[i][1],
                10);

            ApproachPoint(_index + 2,
                _pt2[0] + pointOffsets[Wrap(i + 1, 0, Sides-1)][0],
                _pt2[1] + pointOffsets[Wrap(i + 1, 0, Sides-1)][1],
                10);
        }
    }
}

function MaskEndZone() : __MaskParent() constructor {
    static Height = RES_HEIGHT * 2;
    static Segments = 30;
    static MinStep = 15;
    static MaxStep = 40;
    static MinOffset = 5;
    static MaxOffset = 10;

    __resetTimer = 0;
    __segmentT = []; // Fixed t values (0-1) along the path
    __sideOffsets = []; // Current target side offsets
    __initialized = false;

    // Initialize points for triangle strip: alternating top (lightning) and bottom points
    for (var i = 0; i <= Segments; i++) {
        array_push(points, [0, 0]); // Top point (lightning vertex)
        array_push(points, [0, Height]); // Bottom point
        array_push(__sideOffsets, 0);
    }

    // Line points for outline (just the lightning top)
    for (var i = 0; i < Segments; i++) {
        array_push(pointsLine, points[i * 2], points[(i + 1) * 2]);
    }

    static GenerateSegmentPositions = function() {
        __segmentT = [0]; // Start at 0
        var _cumulative = 0;

        for (var i = 1; i < Segments; i++) {
            _cumulative += random_range(MinStep, MaxStep);
            array_push(__segmentT, _cumulative);
        }

        // Normalize to 0-1 range
        var _total = _cumulative + random_range(MinStep, MaxStep);
        for (var i = 1; i < Segments; i++) {
            __segmentT[i] /= _total;
        }

        array_push(__segmentT, 1); // End at 1
    }

    static GenerateSideOffsets = function() {
        for (var i = 0; i <= Segments; i++) {
            if (i == 0 || i == Segments) {
                __sideOffsets[i] = 0;
            } else {
                var _taper = sin(__segmentT[i] * pi);
                __sideOffsets[i] = choose(-1, 1) * random_range(MinOffset, MaxOffset) * _taper;
            }
        }
    }
    
    static HasCollision = function(_x, _y) {
        return _y > y;
    }

    static Update = function() {
        var _startX = 0;
        var _startY = 0;
        var _endX = RES_WIDTH;
        var _endY = 0;
        if (!__initialized) {
            GenerateSegmentPositions();
            __initialized = true;
        }

        __resetTimer -= 1;
        if (__resetTimer <= 0) {
            GenerateSideOffsets();
            __resetTimer = 3;
        }

        var _dir = point_direction(_startX, _startY, _endX, _endY);
        var _length = point_distance(_startX, _startY, _endX, _endY);
        var _distX = lengthdir_x(1, _dir);
        var _distY = lengthdir_y(1, _dir);
        var _sideX = lengthdir_x(1, _dir + 90);
        var _sideY = lengthdir_y(1, _dir + 90);

        for (var i = 0; i <= Segments; i++) {
            var _topIndex = i * 2;
            var _bottomIndex = _topIndex + 1;

            var _dist = __segmentT[i] * _length;
            var _targetX = _startX + _distX * _dist + _sideX * __sideOffsets[i];
            var _targetY = _startY + _distY * _dist + _sideY * __sideOffsets[i];

            // Top point approaches target
            ApproachPoint(_topIndex, _targetX, _targetY, 10);

            // Bottom point stays below the top point
            SetPoint(_bottomIndex, points[_topIndex][0], points[_topIndex][1] + Height);
        }
    }
}
