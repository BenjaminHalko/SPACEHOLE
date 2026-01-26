#define window_shape_create_empty
/// window_shape_create_empty()->window_shape
var _buf = window_shape_prepare_buffer(8);
if (window_shape_create_empty_raw(buffer_get_address(_buf), ptr(8))) {
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_create_rectangle
/// window_shape_create_rectangle(x1:int, y1:int, x2:int, y2:int)->window_shape
var _buf = window_shape_prepare_buffer(16);
buffer_write(_buf, buffer_s32, argument0);
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
buffer_write(_buf, buffer_s32, argument3);
if (window_shape_create_rectangle_raw(buffer_get_address(_buf), ptr(16))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_create_round_rectangle
/// window_shape_create_round_rectangle(x1:int, y1:int, x2:int, y2:int, w:int, h:int)->window_shape
var _buf = window_shape_prepare_buffer(24);
buffer_write(_buf, buffer_s32, argument0);
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
buffer_write(_buf, buffer_s32, argument3);
buffer_write(_buf, buffer_s32, argument4);
buffer_write(_buf, buffer_s32, argument5);
if (window_shape_create_round_rectangle_raw(buffer_get_address(_buf), ptr(24))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_create_ellipse
/// window_shape_create_ellipse(x1:int, y1:int, x2:int, y2:int)->window_shape
var _buf = window_shape_prepare_buffer(16);
buffer_write(_buf, buffer_s32, argument0);
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
buffer_write(_buf, buffer_s32, argument3);
if (window_shape_create_ellipse_raw(buffer_get_address(_buf), ptr(16))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_create_circle
/// window_shape_create_circle(x:int, y:int, rad:int)->window_shape
var _buf = window_shape_prepare_buffer(12);
buffer_write(_buf, buffer_s32, argument0);
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
if (window_shape_create_circle_raw(buffer_get_address(_buf), ptr(12))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_create_polygon_from_buffer
/// window_shape_create_polygon_from_buffer(b:buffer, mode:int, count:int = -1)->window_shape
var _buf = window_shape_prepare_buffer(25);
var _val_0 = argument[0];
if (buffer_exists(_val_0)) {
	buffer_write(_buf, buffer_u64, int64(buffer_get_address(_val_0)));
	buffer_write(_buf, buffer_s32, buffer_get_size(_val_0));
	buffer_write(_buf, buffer_s32, buffer_tell(_val_0));
} else {
	buffer_write(_buf, buffer_u64, 0);
	buffer_write(_buf, buffer_s32, 0);
	buffer_write(_buf, buffer_s32, 0);
}
buffer_write(_buf, buffer_s32, argument[1]);
if (argument_count >= 3) {
	buffer_write(_buf, buffer_bool, true);
	buffer_write(_buf, buffer_s32, argument[2]);
} else buffer_write(_buf, buffer_bool, false);
if (window_shape_create_polygon_from_buffer_raw(buffer_get_address(_buf), ptr(25))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_create_polygon_from_path_data
/// window_shape_create_polygon_from_path_data(b:buffer, mode:int, closed:bool, smooth:bool, precision:int, count:int)->window_shape ~
var _buf = window_shape_prepare_buffer(30);
var _val_0 = argument0;
if (buffer_exists(_val_0)) {
	buffer_write(_buf, buffer_u64, int64(buffer_get_address(_val_0)));
	buffer_write(_buf, buffer_s32, buffer_get_size(_val_0));
	buffer_write(_buf, buffer_s32, buffer_tell(_val_0));
} else {
	buffer_write(_buf, buffer_u64, 0);
	buffer_write(_buf, buffer_s32, 0);
	buffer_write(_buf, buffer_s32, 0);
}
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_bool, argument2);
buffer_write(_buf, buffer_bool, argument3);
buffer_write(_buf, buffer_s32, argument4);
buffer_write(_buf, buffer_s32, argument5);
if (window_shape_create_polygon_from_path_data_raw(buffer_get_address(_buf), ptr(30))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_create_rectangles_from_rgba
/// window_shape_create_rectangles_from_rgba(b:buffer, tolerance:int, width:int, height:int)->window_shape
var _buf = window_shape_prepare_buffer(28);
var _val_0 = argument0;
if (buffer_exists(_val_0)) {
	buffer_write(_buf, buffer_u64, int64(buffer_get_address(_val_0)));
	buffer_write(_buf, buffer_s32, buffer_get_size(_val_0));
	buffer_write(_buf, buffer_s32, buffer_tell(_val_0));
} else {
	buffer_write(_buf, buffer_u64, 0);
	buffer_write(_buf, buffer_s32, 0);
	buffer_write(_buf, buffer_s32, 0);
}
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
buffer_write(_buf, buffer_s32, argument3);
if (window_shape_create_rectangles_from_rgba_raw(buffer_get_address(_buf), ptr(28))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_duplicate
/// window_shape_duplicate(shape:window_shape)->window_shape
var _buf = window_shape_prepare_buffer(8);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
//*/
if (window_shape_duplicate_raw(buffer_get_address(_buf), ptr(8))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_shift
/// window_shape_shift(shape:window_shape, x:int, y:int)
var _buf = window_shape_prepare_buffer(16);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
//*/
window_shape_shift_raw(buffer_get_address(_buf), ptr(16));

#define window_shape_transform
/// window_shape_transform(shape:window_shape, m11:number, m12:number, m21:number, m22:number, dx:number, dy:number)->window_shape
var _buf = window_shape_prepare_buffer(32);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_f32, argument1);
buffer_write(_buf, buffer_f32, argument2);
buffer_write(_buf, buffer_f32, argument3);
buffer_write(_buf, buffer_f32, argument4);
buffer_write(_buf, buffer_f32, argument5);
buffer_write(_buf, buffer_f32, argument6);
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_f32, argument1);
buffer_write(_buf, buffer_f32, argument2);
buffer_write(_buf, buffer_f32, argument3);
buffer_write(_buf, buffer_f32, argument4);
buffer_write(_buf, buffer_f32, argument5);
buffer_write(_buf, buffer_f32, argument6);
//*/
if (window_shape_transform_raw(buffer_get_address(_buf), ptr(32))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_combine
/// window_shape_combine(shape1:window_shape, shape2:window_shape, op:int)->window_shape
var _buf = window_shape_prepare_buffer(20);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
_box_0.__id__ = 0;
buffer_write(_buf, buffer_u64, int64(_id_0));
var _box_0 = argument1;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
_box_0.__id__ = 0;
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument2);
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
_box_0[@1] = 0;
buffer_write(_buf, buffer_u64, int64(_id_0));
var _box_0 = argument1;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
_box_0[@1] = 0;
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument2);
//*/
if (window_shape_combine_raw(buffer_get_address(_buf), ptr(20))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_combine_nc
/// window_shape_combine_nc(shape1:window_shape, shape2:window_shape, op:int)->window_shape
var _buf = window_shape_prepare_buffer(20);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
var _box_0 = argument1;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument2);
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
var _box_0 = argument1;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument2);
//*/
if (window_shape_combine_nc_raw(buffer_get_address(_buf), ptr(20))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = new window_shape(_id_0);
	} else _box_0 = undefined;
	return _box_0;
	/*/
	var _id_0 = buffer_read(_buf, buffer_u64);
	var _box_0;
	if (_id_0 != 0) {
		_box_0 = array_create(2);
		_box_0[0] = global.__ptrt_window_shape;
		_box_0[1] = _id_0;
	} else _box_0 = undefined;
	return _box_0;
	//*/
} else return undefined;

#define window_shape_concat
/// window_shape_concat(dest:window_shape, shape:window_shape, op:int)->bool
var _buf = window_shape_prepare_buffer(20);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
var _box_0 = argument1;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument2);
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
var _box_0 = argument1;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument2);
//*/
return window_shape_concat_raw(buffer_get_address(_buf), ptr(20));

#define window_shape_concat_nc
/// window_shape_concat_nc(dest:window_shape, shape:window_shape, op:int)->bool
var _buf = window_shape_prepare_buffer(20);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
var _box_0 = argument1;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument2);
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
var _box_0 = argument1;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument2);
//*/
return window_shape_concat_nc_raw(buffer_get_address(_buf), ptr(20));

#define window_shape_contains_point
/// window_shape_contains_point(shape:window_shape, x:int, y:int)->bool
var _buf = window_shape_prepare_buffer(16);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
//*/
return window_shape_contains_point_raw(buffer_get_address(_buf), ptr(16));

#define window_shape_contains_rectangle
/// window_shape_contains_rectangle(shape:window_shape, x1:int, y1:int, x2:int, y2:int)->bool
var _buf = window_shape_prepare_buffer(24);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
buffer_write(_buf, buffer_s32, argument3);
buffer_write(_buf, buffer_s32, argument4);
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
buffer_write(_buf, buffer_s32, argument1);
buffer_write(_buf, buffer_s32, argument2);
buffer_write(_buf, buffer_s32, argument3);
buffer_write(_buf, buffer_s32, argument4);
//*/
return window_shape_contains_rectangle_raw(buffer_get_address(_buf), ptr(24));

#define window_shape_set
/// window_shape_set(shape:window_shape)
var _buf = window_shape_prepare_buffer(8);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
_box_0.__id__ = 0;
buffer_write(_buf, buffer_u64, int64(_id_0));
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
_box_0[@1] = 0;
buffer_write(_buf, buffer_u64, int64(_id_0));
//*/
window_shape_set_raw(buffer_get_address(_buf), ptr(8));

#define window_shape_set_nc
/// window_shape_set_nc(shape:window_shape)
var _buf = window_shape_prepare_buffer(8);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, int64(_id_0));
//*/
window_shape_set_nc_raw(buffer_get_address(_buf), ptr(8));

#define window_shape_reset
/// window_shape_reset()
var _buf = window_shape_prepare_buffer(1);
window_shape_reset_raw(buffer_get_address(_buf), ptr(1));

#define window_shape_destroy
/// window_shape_destroy(shape:window_shape)
var _buf = window_shape_prepare_buffer(8);
// GMS >= 2.3:
var _box_0 = argument0;
if (instanceof(_box_0) != "window_shape") { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0.__id__
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
_box_0.__id__ = 0;
buffer_write(_buf, buffer_u64, int64(_id_0));
/*/
var _box_0 = argument0;
if (!is_array(_box_0) || _box_0[0] != global.__ptrt_window_shape) { show_error("Expected a window_shape, got " + string(_box_0), true); exit }
var _id_0 = _box_0[1];
if (_id_0 == 0) { show_error("This window_shape is destroyed.", true); exit; }
_box_0[@1] = 0;
buffer_write(_buf, buffer_u64, int64(_id_0));
//*/
window_shape_destroy_raw(buffer_get_address(_buf), ptr(8));

