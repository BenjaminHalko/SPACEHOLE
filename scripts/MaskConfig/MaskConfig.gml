function __MaskParent() constructor {
    x = 0;
    y = 0;
    size = 0;
    attack = 0;
    points = [];
    pointsLine = [];
    pointOffsets = [];

    static Draw = function() {
        var _ptsLen = array_length(points);
        
        draw_primitive_begin(pr_trianglelist);
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
    
    /// @param {real} left
    /// @param {real} top
    /// @param {real} right
    /// @param {real} bottom
    static HasCollision = function(_left, _top, _right, _bottom) {
        var _ptsLen = array_length(points);
        for (var i = 0; i < _ptsLen-3; i++) {
            if (!rectangle_in_triangle(
                _left,
                _top,
                _right,
                _bottom,
                x + points[i][0],
                y + points[i][1],
                x + points[i+1][0],
                y + points[i+1][1],
                x + points[i+2][0],
                y + points[i+2][1]
            )) {
                return false;
            }
        }
        return true;
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
    static Sides = 48;
    
    repeat(Sides) {
        array_push(points, [0, 0], [0, 0], [0, 0]);
        var _len = array_length(points);
        array_push(pointsLine, points[_len - 2], points[_len - 1]);
        array_push(pointOffsets, [0, 0], [0, 0]);
    }
    
    static UpdateOffsets = function() {
        var _pointOffsetLen = array_length(pointOffsets);
        for(var i = 0; i < _pointOffsetLen; i++) {
            if (irandom(5) != 0) continue;
            var _angle = random(360);
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
