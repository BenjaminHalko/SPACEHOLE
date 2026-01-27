function LightningEffect() constructor {
	__pos = [];
	__sideOffset = [];
	__resetOffsetTimer = 0;
	__color = #ffe8f3;
	__glow = #ff006c;
	
	static Step = function() {
		__resetOffsetTimer -= 1;
		if (__resetOffsetTimer <= 0) {
			__pos = [];
			__sideOffset = [];
			__resetOffsetTimer = 3;
		}
	}

	///	@param		{real}	x1		Start point on X
	///	@param		{real}	y1		Start point on Y
	///	@param		{real}	x2		End point on X
	///	@param		{real}	y2		End point on Y
	///	@param		{real}	minX	Min length of a branch
	///	@param		{real}	maxX	Max length of a branch
	///	@param		{real}	minY	Min height of a branch
	///	@param		{real}	maxY	Max height of a branch
	/// @returns	{real} number of segments drawn.
	static Draw = function(_x1, _y1, _x2, _y2, _minX, _maxX, _minY, _maxY, _frozen = false) {
		var _index, _increment, _sideOffset, _length, _distanceX, _distanceY;
		var _sideX, _sideY, _pointX, _pointY, _currentX, _currentY;
		var _drawn = 0;
		//Check the total length of the lightning
		_length = point_distance(_x1, _y1, _x2, _y2);
		if (_length != 0) { //Skip code is the lightning is 0 pixels wide, for whatever reason
			// main direction: where to shoot, get and set endpoint!
			_increment = point_direction(_x1, _y1, _x2, _y2);
			_distanceX = lengthdir_x(1, _increment); 
			_distanceY = lengthdir_y(1, _increment);

			// side direction:
			_increment += 90;
			_sideX = lengthdir_x(1, _increment); 
			_sideY = lengthdir_y(1, _increment)

			// first point coordinates:
			_pointX = _x1; 
			_pointY = _y1;
			//Reset increment to 0 to run the code correctly
			_increment = 0;
		
			//Draw
			for (_index = 0; _index <= 50; _index += 1) {
				//How long is each line
				if (array_length(__pos) <= _index) {
					__pos[_index] = _increment + random_range(_minX, _maxX);
				}
				_increment = __pos[_index];
				//Sideways offset for each line
				if (array_length(__sideOffset) <= _index) {
					__sideOffset[_index] = choose(-1, +1) * (_minY + (_maxY - _minY) * lengthdir_y(random(1), _increment / _length * 180));
				}
				_sideOffset = __sideOffset[_index];
			
				//Update current end coordinates
				if (_increment < _length) {
					_currentX = _x1 + _distanceX * _increment + _sideX * _sideOffset;
					_currentY = _y1 + _distanceY * _increment + _sideY * _sideOffset;
				} else {
					_currentX = _x2;
					_currentY = _y2;
				}
				
				//Draw Glow
				//draw_set_alpha(_alpha * 0.65);
				//draw_set_color(__glow);
			    //draw_line_width(_pointX, _pointY, _currentX, _currentY, 3);
				
				//Draw Lightning itself
				//draw_set_color(__color);
			    //draw_set_alpha(_alpha * 1.0);
			    draw_line(_pointX, _pointY, _currentX, _currentY);
				
				//Count total drawn lines
				_drawn += 1;
			    // exit condition:
			    if (_increment >= _length) {
					break;
				}
				
			    // update previous point coordinates, get next branch
				_pointX = _currentX;  // set new branch start point to last endpoint
				_pointY = _currentY;
			}
		} else {
			print("Error - Trying to draw lightning of 0 width");
		}
		
		return _drawn; //For debug purposes
	}
}