#pragma once
#include "window_shape.h"
#include <vector>
#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
#include <optional>
#endif
#include <stdint.h>
#include <cstring>
#include <tuple>
using namespace std;

#define dllg /* tag */
#define dllgm /* tag;mangled */

#if defined(_WINDOWS)
#define dllx extern "C" __declspec(dllexport)
#define dllm __declspec(dllexport)
#elif defined(GNUC)
#define dllx extern "C" __attribute__ ((visibility("default"))) 
#define dllm __attribute__ ((visibility("default"))) 
#else
#define dllx extern "C"
#define dllm /* */
#endif

#ifdef _WINDOWS
/// auto-generates a window_handle() on GML side
using GAME_HWND = HWND;
#endif

/// auto-generates an asset_get_index("argument_name") on GML side
typedef int gml_asset_index_of;
/// Wraps a C++ pointer for GML.
template <typename T> using gml_ptr = T*;
/// Same as gml_ptr, but replaces the GML-side pointer by a nullptr after passing it to C++
template <typename T> using gml_ptr_destroy = T*;
/// Wraps any ID (or anything that casts to int64, really) for GML.
template <typename T> using gml_id = T;
/// Same as gml_id, but replaces the GML-side ID by a 0 after passing it to C++
template <typename T> using gml_id_destroy = T;

class gml_buffer {
private:
	uint8_t* _data;
	int32_t _size;
	int32_t _tell;
public:
	gml_buffer() : _data(nullptr), _tell(0), _size(0) {}
	gml_buffer(uint8_t* data, int32_t size, int32_t tell) : _data(data), _size(size), _tell(tell) {}

	inline uint8_t* data() { return _data; }
	inline int32_t tell() { return _tell; }
	inline int32_t size() { return _size; }
};

class gml_istream {
	uint8_t* pos;
	uint8_t* start;
public:
	gml_istream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

	template<class T> T read() {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be read");
		T result{};
		std::memcpy(&result, pos, sizeof(T));
		pos += sizeof(T);
		return result;
	}

	char* read_string() {
		char* r = (char*)pos;
		while (*pos != 0) pos++;
		pos++;
		return r;
	}

	template<class T> std::vector<T> read_vector() {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be read");
		auto n = read<uint32_t>();
		std::vector<T> vec(n);
		std::memcpy(vec.data(), pos, sizeof(T) * n);
		pos += sizeof(T) * n;
		return vec;
	}
	std::vector<const char*> read_string_vector() {
		auto n = read<uint32_t>();
		std::vector<const char*> vec(n);
		for (auto i = 0u; i < n; i++) {
			vec[i] = read_string();
		}
		return vec;
	}

	gml_buffer read_gml_buffer() {
		auto _data = (uint8_t*)read<int64_t>();
		auto _size = read<int32_t>();
		auto _tell = read<int32_t>();
		return gml_buffer(_data, _size, _tell);
	}

	#pragma region Tuples
	#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
	template<typename... Args>
	std::tuple<Args...> read_tuple() {
		std::tuple<Args...> tup;
		std::apply([this](auto&&... arg) {
			((
				arg = this->read<std::remove_reference_t<decltype(arg)>>()
				), ...);
			}, tup);
		return tup;
	}

	template<class T> optional<T> read_optional() {
		if (read<bool>()) {
			return read<T>;
		} else return {};
	}
	#else
	template<class A, class B> std::tuple<A, B> read_tuple() {
		A a = read<A>();
		B b = read<B>();
		return std::tuple<A, B>(a, b);
	}

	template<class A, class B, class C> std::tuple<A, B, C> read_tuple() {
		A a = read<A>();
		B b = read<B>();
		C c = read<C>();
		return std::tuple<A, B, C>(a, b, c);
	}

	template<class A, class B, class C, class D> std::tuple<A, B, C, D> read_tuple() {
		A a = read<A>();
		B b = read<B>();
		C c = read<C>();
		D d = read<d>();
		return std::tuple<A, B, C, D>(a, b, c, d);
	}
	#endif
};

class gml_ostream {
	uint8_t* pos;
	uint8_t* start;
public:
	gml_ostream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

	template<class T> void write(T val) {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be write");
		memcpy(pos, &val, sizeof(T));
		pos += sizeof(T);
	}

	void write_string(const char* s) {
		for (int i = 0; s[i] != 0; i++) write<char>(s[i]);
		write<char>(0);
	}

	template<class T> void write_vector(std::vector<T>& vec) {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be write");
		auto n = vec.size();
		write<uint32_t>((uint32_t)n);
		memcpy(pos, vec.data(), n * sizeof(T));
		pos += n * sizeof(T);
	}

	void write_string_vector(std::vector<const char*> vec) {
		auto n = vec.size();
		write<uint32_t>((uint32_t)n);
		for (auto i = 0u; i < n; i++) {
			write_string(vec[i]);
		}
	}

	#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
	template<typename... Args>
	void write_tuple(std::tuple<Args...> tup) {
		std::apply([this](auto&&... arg) {
			(this->write(arg), ...);
			}, tup);
	}

	template<class T> void write_optional(optional<T>& val) {
		auto hasValue = val.has_value();
		write<bool>(hasValue);
		if (hasValue) write<T>(val.value());
	}
	#else
	template<class A, class B> void write_tuple(std::tuple<A, B>& tup) {
		write<A>(std::get<0>(tup));
		write<B>(std::get<1>(tup));
	}
	template<class A, class B, class C> void write_tuple(std::tuple<A, B, C>& tup) {
		write<A>(std::get<0>(tup));
		write<B>(std::get<1>(tup));
		write<C>(std::get<2>(tup));
	}
	template<class A, class B, class C, class D> void write_tuple(std::tuple<A, B, C, D>& tup) {
		write<A>(std::get<0>(tup));
		write<B>(std::get<1>(tup));
		write<C>(std::get<2>(tup));
		write<D>(std::get<3>(tup));
	}
	#endif
};
//{{NO_DEPENDENCIES}}
// Microsoft Visual C++ generated include file.
// Used by window_shape.rc

// Next default values for new objects
// 
#ifdef APSTUDIO_INVOKED
#ifndef APSTUDIO_READONLY_SYMBOLS
#define _APS_NEXT_RESOURCE_VALUE        101
#define _APS_NEXT_COMMAND_VALUE         40001
#define _APS_NEXT_CONTROL_VALUE         1001
#define _APS_NEXT_SYMED_VALUE           101
#endif
#endif
// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include "window_shape.h"

#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
#define tiny_cpp17
#endif

#define _trace // requires user32.lib;Kernel32.lib

#ifdef TINY // common things to implement
//#define tiny_memset
//#define tiny_memcpy
#define tiny_malloc
//#define tiny_dtoui3
#endif

#ifdef _trace
static constexpr char trace_prefix[] = "[window_shape] ";
#ifdef _WINDOWS
void trace(const char* format, ...);
#else
#define trace(...) { printf("%s", trace_prefix); printf(__VA_ARGS__); printf("\n"); fflush(stdout); }
#endif
#endif

#pragma region typed memory helpers
template<typename T> T* malloc_arr(size_t count) {
	return (T*)malloc(sizeof(T) * count);
}
template<typename T> T* realloc_arr(T* arr, size_t count) {
	return (T*)realloc(arr, sizeof(T) * count);
}
template<typename T> T* memcpy_arr(T* dst, const T* src, size_t count) {
	return (T*)memcpy(dst, src, sizeof(T) * count);
}
#pragma endregion

#include "gml_ext.h"

// TODO: reference additional headers your program requires here
#pragma once

// Including SDKDDKVer.h defines the highest available Windows platform.

// If you wish to build your application for a previous Windows platform, include WinSDKVer.h and
// set the _WIN32_WINNT macro to the platform you wish to support before including SDKDDKVer.h.

#include <SDKDDKVer.h>
#pragma once
#include "stdafx.h"

template<typename T> class tiny_array {
	T* _data;
	size_t _size;
	size_t _capacity;

	bool add_impl(T value) {
		if (_size >= _capacity) {
			auto new_capacity = _capacity * 2;
			auto new_data = realloc_arr(_data, _capacity);
			if (new_data == nullptr) {
				trace("Failed to reallocate %u bytes in tiny_array::add", sizeof(T) * new_capacity);
				return false;
			}
			for (size_t i = _capacity; i < new_capacity; i++) new_data[i] = {};
			_data = new_data;
			_capacity = new_capacity;
		}
		_data[_size++] = value;
		return true;
	}
public:
	tiny_array() { }
	tiny_array(size_t capacity) { init(capacity); }
	inline void init(size_t capacity = 4) {
		if (capacity < 1) capacity = 1;
		_size = 0;
		_capacity = capacity;
		_data = malloc_arr<T>(capacity);
	}
	inline void free() {
		if (_data) {
			::free(_data);
			_data = nullptr;
		}
	}

	size_t size() { return _size; }
	size_t capacity() { return _capacity; }
	T* data() { return _data; }

	bool resize(size_t newsize, T value = {}) {
		if (newsize > _capacity) {
			auto new_data = realloc_arr(_data, newsize);
			if (new_data == nullptr) {
				trace("Failed to reallocate %u bytes in tiny_array::resize", sizeof(T) * newsize);
				return false;
			}
			_data = new_data;
			_capacity = newsize;
		}
		for (size_t i = _size; i < newsize; i++) _data[i] = value;
		for (size_t i = _size; --i >= newsize;) _data[i] = value;
		_size = newsize;
		return true;
	}

	#ifdef tiny_cpp17
	template<class... Args>
	inline bool add(Args... values) {
		return (add_impl(values) && ...);
	}
	#else
	inline void add(T value) {
		add_impl(value);
	}
	#endif

	bool remove(size_t index, size_t count = 1) {
		size_t end = index + count;
		if (end < _size) memcpy_arr(_data + start, _data + end, _size - end);
		_size -= end - index;
		return true;
	}

	bool set(T* values, size_t count) {
		if (!resize(count)) return false;
		memcpy_arr(_data, values, count);
		return true;
	}
	template<size_t count> inline bool set(T(&values)[count]) {
		return set(values, count);
	}

	T operator[] (size_t index) const { return _data[index]; }
	T& operator[] (size_t index) { return _data[index]; }
};#pragma once
#include "targetver.h"

#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers
#include <windows.h>

using window_shape = HRGN;
#include "gml_ext.h"
#include "window_shape.h"
extern gml_id<window_shape> window_shape_create_empty();
dllx double window_shape_create_empty_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_id<window_shape> _ret = window_shape_create_empty();
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_create_rectangle(int x1, int y1, int x2, int y2);
dllx double window_shape_create_rectangle_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _arg_x1;
	_arg_x1 = _in.read<int>();
	int _arg_y1;
	_arg_y1 = _in.read<int>();
	int _arg_x2;
	_arg_x2 = _in.read<int>();
	int _arg_y2;
	_arg_y2 = _in.read<int>();
	gml_id<window_shape> _ret = window_shape_create_rectangle(_arg_x1, _arg_y1, _arg_x2, _arg_y2);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_create_round_rectangle(int x1, int y1, int x2, int y2, int w, int h);
dllx double window_shape_create_round_rectangle_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _arg_x1;
	_arg_x1 = _in.read<int>();
	int _arg_y1;
	_arg_y1 = _in.read<int>();
	int _arg_x2;
	_arg_x2 = _in.read<int>();
	int _arg_y2;
	_arg_y2 = _in.read<int>();
	int _arg_w;
	_arg_w = _in.read<int>();
	int _arg_h;
	_arg_h = _in.read<int>();
	gml_id<window_shape> _ret = window_shape_create_round_rectangle(_arg_x1, _arg_y1, _arg_x2, _arg_y2, _arg_w, _arg_h);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_create_ellipse(int x1, int y1, int x2, int y2);
dllx double window_shape_create_ellipse_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _arg_x1;
	_arg_x1 = _in.read<int>();
	int _arg_y1;
	_arg_y1 = _in.read<int>();
	int _arg_x2;
	_arg_x2 = _in.read<int>();
	int _arg_y2;
	_arg_y2 = _in.read<int>();
	gml_id<window_shape> _ret = window_shape_create_ellipse(_arg_x1, _arg_y1, _arg_x2, _arg_y2);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_create_circle(int x, int y, int rad);
dllx double window_shape_create_circle_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _arg_x;
	_arg_x = _in.read<int>();
	int _arg_y;
	_arg_y = _in.read<int>();
	int _arg_rad;
	_arg_rad = _in.read<int>();
	gml_id<window_shape> _ret = window_shape_create_circle(_arg_x, _arg_y, _arg_rad);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_create_polygon_from_buffer(gml_buffer b, int mode, int count);
dllx double window_shape_create_polygon_from_buffer_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_buffer _arg_b;
	_arg_b = _in.read_gml_buffer();
	int _arg_mode;
	_arg_mode = _in.read<int>();
	int _arg_count;
	if (_in.read<bool>()) {
		_arg_count = _in.read<int>();
	} else _arg_count = -1;
	gml_id<window_shape> _ret = window_shape_create_polygon_from_buffer(_arg_b, _arg_mode, _arg_count);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_create_polygon_from_path_data(gml_buffer b, int mode, bool closed, bool smooth, int precision, int count);
dllx double window_shape_create_polygon_from_path_data_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_buffer _arg_b;
	_arg_b = _in.read_gml_buffer();
	int _arg_mode;
	_arg_mode = _in.read<int>();
	bool _arg_closed;
	_arg_closed = _in.read<bool>();
	bool _arg_smooth;
	_arg_smooth = _in.read<bool>();
	int _arg_precision;
	_arg_precision = _in.read<int>();
	int _arg_count;
	_arg_count = _in.read<int>();
	gml_id<window_shape> _ret = window_shape_create_polygon_from_path_data(_arg_b, _arg_mode, _arg_closed, _arg_smooth, _arg_precision, _arg_count);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_create_rectangles_from_rgba(gml_buffer b, int tolerance, int width, int height);
dllx double window_shape_create_rectangles_from_rgba_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_buffer _arg_b;
	_arg_b = _in.read_gml_buffer();
	int _arg_tolerance;
	_arg_tolerance = _in.read<int>();
	int _arg_width;
	_arg_width = _in.read<int>();
	int _arg_height;
	_arg_height = _in.read<int>();
	gml_id<window_shape> _ret = window_shape_create_rectangles_from_rgba(_arg_b, _arg_tolerance, _arg_width, _arg_height);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_duplicate(gml_id<window_shape> shape);
dllx double window_shape_duplicate_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_id<window_shape> _arg_shape;
	_arg_shape = (gml_id<window_shape>)_in.read<int64_t>();;
	gml_id<window_shape> _ret = window_shape_duplicate(_arg_shape);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern void window_shape_shift(gml_id<window_shape> shape, int x, int y);
dllx double window_shape_shift_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id<window_shape> _arg_shape;
	_arg_shape = (gml_id<window_shape>)_in.read<int64_t>();;
	int _arg_x;
	_arg_x = _in.read<int>();
	int _arg_y;
	_arg_y = _in.read<int>();
	window_shape_shift(_arg_shape, _arg_x, _arg_y);
	return 1;
}

extern gml_id<window_shape> window_shape_transform(gml_id<window_shape> shape, float m11, float m12, float m21, float m22, float dx, float dy);
dllx double window_shape_transform_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_id<window_shape> _arg_shape;
	_arg_shape = (gml_id<window_shape>)_in.read<int64_t>();;
	float _arg_m11;
	_arg_m11 = _in.read<float>();
	float _arg_m12;
	_arg_m12 = _in.read<float>();
	float _arg_m21;
	_arg_m21 = _in.read<float>();
	float _arg_m22;
	_arg_m22 = _in.read<float>();
	float _arg_dx;
	_arg_dx = _in.read<float>();
	float _arg_dy;
	_arg_dy = _in.read<float>();
	gml_id<window_shape> _ret = window_shape_transform(_arg_shape, _arg_m11, _arg_m12, _arg_m21, _arg_m22, _arg_dx, _arg_dy);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_combine(gml_id_destroy<window_shape> shape1, gml_id_destroy<window_shape> shape2, int op);
dllx double window_shape_combine_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_id_destroy<window_shape> _arg_shape1;
	_arg_shape1 = (gml_id_destroy<window_shape>)_in.read<int64_t>();;
	gml_id_destroy<window_shape> _arg_shape2;
	_arg_shape2 = (gml_id_destroy<window_shape>)_in.read<int64_t>();;
	int _arg_op;
	_arg_op = _in.read<int>();
	gml_id<window_shape> _ret = window_shape_combine(_arg_shape1, _arg_shape2, _arg_op);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern gml_id<window_shape> window_shape_combine_nc(gml_id<window_shape> shape1, gml_id<window_shape> shape2, int op);
dllx double window_shape_combine_nc_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_id<window_shape> _arg_shape1;
	_arg_shape1 = (gml_id<window_shape>)_in.read<int64_t>();;
	gml_id<window_shape> _arg_shape2;
	_arg_shape2 = (gml_id<window_shape>)_in.read<int64_t>();;
	int _arg_op;
	_arg_op = _in.read<int>();
	gml_id<window_shape> _ret = window_shape_combine_nc(_arg_shape1, _arg_shape2, _arg_op);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_ret);
	return 1;
}

extern bool window_shape_concat(gml_id<window_shape> dest, gml_id<window_shape> shape, int op);
dllx double window_shape_concat_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id<window_shape> _arg_dest;
	_arg_dest = (gml_id<window_shape>)_in.read<int64_t>();;
	gml_id<window_shape> _arg_shape;
	_arg_shape = (gml_id<window_shape>)_in.read<int64_t>();;
	int _arg_op;
	_arg_op = _in.read<int>();
	return window_shape_concat(_arg_dest, _arg_shape, _arg_op);
}

extern bool window_shape_concat_nc(gml_id<window_shape> dest, gml_id<window_shape> shape, int op);
dllx double window_shape_concat_nc_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id<window_shape> _arg_dest;
	_arg_dest = (gml_id<window_shape>)_in.read<int64_t>();;
	gml_id<window_shape> _arg_shape;
	_arg_shape = (gml_id<window_shape>)_in.read<int64_t>();;
	int _arg_op;
	_arg_op = _in.read<int>();
	return window_shape_concat_nc(_arg_dest, _arg_shape, _arg_op);
}

extern bool window_shape_contains_point(gml_id<window_shape> shape, int x, int y);
dllx double window_shape_contains_point_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id<window_shape> _arg_shape;
	_arg_shape = (gml_id<window_shape>)_in.read<int64_t>();;
	int _arg_x;
	_arg_x = _in.read<int>();
	int _arg_y;
	_arg_y = _in.read<int>();
	return window_shape_contains_point(_arg_shape, _arg_x, _arg_y);
}

extern bool window_shape_contains_rectangle(gml_id<window_shape> shape, int x1, int y1, int x2, int y2);
dllx double window_shape_contains_rectangle_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id<window_shape> _arg_shape;
	_arg_shape = (gml_id<window_shape>)_in.read<int64_t>();;
	int _arg_x1;
	_arg_x1 = _in.read<int>();
	int _arg_y1;
	_arg_y1 = _in.read<int>();
	int _arg_x2;
	_arg_x2 = _in.read<int>();
	int _arg_y2;
	_arg_y2 = _in.read<int>();
	return window_shape_contains_rectangle(_arg_shape, _arg_x1, _arg_y1, _arg_x2, _arg_y2);
}

extern void window_shape_set(gml_id_destroy<window_shape> shape);
dllx double window_shape_set_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id_destroy<window_shape> _arg_shape;
	_arg_shape = (gml_id_destroy<window_shape>)_in.read<int64_t>();;
	window_shape_set(_arg_shape);
	return 1;
}

extern void window_shape_set_nc(gml_id<window_shape> shape);
dllx double window_shape_set_nc_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id<window_shape> _arg_shape;
	_arg_shape = (gml_id<window_shape>)_in.read<int64_t>();;
	window_shape_set_nc(_arg_shape);
	return 1;
}

extern void window_shape_reset();
dllx double window_shape_reset_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	window_shape_reset();
	return 1;
}

extern void window_shape_destroy(gml_id_destroy<window_shape> shape);
dllx double window_shape_destroy_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id_destroy<window_shape> _arg_shape;
	_arg_shape = (gml_id_destroy<window_shape>)_in.read<int64_t>();;
	window_shape_destroy(_arg_shape);
	return 1;
}

// stdafx.cpp : source file that includes just the standard includes
// window_shape.pch will be the pre-compiled header
// stdafx.obj will contain the pre-compiled type information

#include "stdafx.h"
#include <strsafe.h>
#ifdef tiny_dtoui3
#include <intrin.h>
#endif

#if _WINDOWS
// http://computer-programming-forum.com/7-vc.net/07649664cea3e3d7.htm
extern "C" int _fltused = 0;
#endif

// TODO: reference any additional headers you need in STDAFX.H
// and not in this file
#ifdef _trace
#ifdef _WINDOWS
// https://yal.cc/printf-without-standard-library/
void trace(const char* pszFormat, ...) {
	char buf[1024 + sizeof(trace_prefix)];
	wsprintfA(buf, "%s", trace_prefix);
	va_list argList;
	va_start(argList, pszFormat);
	wvsprintfA(buf + sizeof(trace_prefix) - 1, pszFormat, argList);
	va_end(argList);
	DWORD done;
	auto len = strlen(buf);
	buf[len] = '\n';
	buf[++len] = 0;
	WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), buf, (DWORD)len, &done, NULL);
}
#endif
#endif

#pragma warning(disable: 28251 28252)

#ifdef tiny_memset
#pragma function(memset)
void* __cdecl memset(void* _Dst, _In_ int _Val,_In_ size_t _Size) {
	auto ptr = static_cast<uint8_t*>(_Dst);
	while (_Size) {
		*ptr++ = _Val;
		_Size--;
	}
	return _Dst;
}
#endif

#ifdef tiny_memcpy
#pragma function(memcpy)
void* memcpy(void* _Dst, const void* _Src, size_t _Size) {
	auto src8 = static_cast<const uint64_t*>(_Src);
	auto dst8 = static_cast<uint64_t*>(_Dst);
	for (; _Size > 32; _Size -= 32) {
		*dst8++ = *src8++;
		*dst8++ = *src8++;
		*dst8++ = *src8++;
		*dst8++ = *src8++;
	}
	for (; _Size > 8; _Size -= 8) *dst8++ = *src8++;
	//
	auto src1 = (const uint8_t*)(src8);
	auto dst1 = (uint8_t*)(dst8);
	for (; _Size != 0; _Size--) *dst1++ = *src1++;
	return _Dst;
}
#endif

#ifdef tiny_malloc
void* __cdecl malloc(size_t _Size) {
	return HeapAlloc(GetProcessHeap(), 0, _Size);
}
void* __cdecl realloc(void* _Block, size_t _Size) {
	return HeapReAlloc(GetProcessHeap(), 0, _Block, _Size);
}
void __cdecl free(void* _Block) {
	HeapFree(GetProcessHeap(), 0, _Block);
}
#endif

#ifdef tiny_dtoui3
// https:/stackoverflow.com/a/55011686/5578773
extern "C" unsigned int _dtoui3(const double x) {
	return (unsigned int)_mm_cvttsd_si32(_mm_set_sd(x));
}
#endif

#pragma warning(default: 28251 28252)
/// @author YellowAfterlife

#include <dwmapi.h>
#include "stdafx.h"

// @dllg:docname window_shape window_shape

dllg gml_id<window_shape> window_shape_create_empty() {
	return CreateRectRgn(0, 0, 0, 0);
}
dllg gml_id<window_shape> window_shape_create_rectangle(int x1, int y1, int x2, int y2) {
	return CreateRectRgn(x1, y1, x2, y2);
}
dllg gml_id<window_shape> window_shape_create_round_rectangle(int x1, int y1, int x2, int y2, int w, int h) {
	return CreateRoundRectRgn(x1, y1, x2, y2, w, h);
}
dllg gml_id<window_shape> window_shape_create_ellipse(int x1, int y1, int x2, int y2) {
	return CreateEllipticRgn(x1, y1, x2, y2);
}
dllg gml_id<window_shape> window_shape_create_circle(int x, int y, int rad) {
	return CreateEllipticRgn(x - rad, y - rad, x + rad, y + rad);
}

///
enum class window_shape_polygon_mode {
	alternate = 1,
	winding = 2,
};
dllg gml_id<window_shape> window_shape_create_polygon_from_buffer(gml_buffer b, int mode, int count = -1) {
	static_assert(sizeof(POINT) == 8);
	static_assert(offsetof(POINT, x) == 0);
	static_assert((int)window_shape_polygon_mode::alternate == ALTERNATE);
	static_assert((int)window_shape_polygon_mode::winding == WINDING);
	if (count == -1) count = b.tell() / 8;
	return CreatePolygonRgn((POINT*)b.data(), count, mode);
}
/// ~
dllg gml_id<window_shape> window_shape_create_polygon_from_path_data(gml_buffer b, int mode, bool closed, bool smooth, int precision, int count) {
	struct GmlPathPoint { double x, y; };
	static_assert(sizeof(GmlPathPoint) == 16);

	auto in = (GmlPathPoint*)b.data();
	auto points = (POINT*)(in + count);
	auto out = points;
	if (!smooth) {
		if (b.size() < sizeof(GmlPathPoint) * count + sizeof(POINT) * count) return 0;
		for (int i = 0; i < count; i++, in++, out++) {
			out->x = (int)in->x;
			out->y = (int)in->y;
		}
		return CreatePolygonRgn(points, count, mode);
	}
	if (b.size() < sizeof(GmlPathPoint) * count + sizeof(POINT) * precision * count) return 0;
	auto step = 1. / (double)precision;
	int last = count - 1;
	auto curr = &in[closed ? last : 0];
	auto next = &in[0];
	auto found = 0;
	for (int i = 0; i < count; i++) {
		auto prev = curr;
		curr = next;
		if (i == last) {
			next = &in[closed ? 0 : last];
		} else {
			next = &in[i + 1];
		}

		auto pos = 0.;
		for (int k = 0; k < precision; k++) {
			#define X(x) out->x = (int)(0.5f * (((prev->x - 2. * curr->x + next->x) * pos + 2. * (curr->x - prev->x)) * pos + prev->x + curr->x));
			X(x);
			X(y);
			#undef X
			// trace("%d: i=%d p=%d x=%d y=%d", found++, i, (int)(pos * 1000.), out->x, out->y);
			out++;
			pos += step;
		}
	}
	return CreatePolygonRgn(points, count * precision, mode);
}

inline void window_shape_create_rectangles_from_rgba_1(window_shape result, int y, int x1, int x2) {
	auto tmp = CreateRectRgn(x1, y, x2, y + 1);
	CombineRgn(result, result, tmp, RGN_OR);
	DeleteObject(tmp);
}
dllg gml_id<window_shape> window_shape_create_rectangles_from_rgba(gml_buffer b, int tolerance, int width, int height) {
	int count = width * height;
	struct rgba { uint8_t r, g, b, a; };
	auto ptr = (rgba*)b.data();
	auto result = window_shape_create_empty();
	for (int y = 0; y < height; y++) {
		int start = -1, x;
		for (x = 0; x < width; x++) {
			auto px = *ptr++;
			if (px.a <= tolerance) {
				if (start >= 0) {
					window_shape_create_rectangles_from_rgba_1(result, y, start, x);
					start = -1;
				}
			} else {
				if (start < 0) start = x;
			}
		}
		if (start >= 0) {
			window_shape_create_rectangles_from_rgba_1(result, y, start, x);
		}
	}
	return result;
}

dllg gml_id<window_shape> window_shape_duplicate(gml_id<window_shape> shape) {
	auto result = window_shape_create_empty();
	if (CombineRgn(result, shape, result, RGN_COPY) == ERROR) {
		DeleteObject(result);
		result = (window_shape)0;
	}
	return result;
}

dllg void window_shape_shift(gml_id<window_shape> shape, int x, int y) {
	OffsetRgn(shape, x, y);
}
dllg gml_id<window_shape> window_shape_transform(gml_id<window_shape> shape, float m11, float m12, float m21, float m22, float dx, float dy) {
	auto size = GetRegionData(shape, 0, NULL);
	auto data = (RGNDATA*)malloc(size);
	if (GetRegionData(shape, size, data) == 0) return 0;
	XFORM tm;
	tm.eM11 = m11;
	tm.eM12 = m12;
	tm.eM21 = m21;
	tm.eM22 = m22;
	tm.eDx = dx;
	tm.eDy = dy;
	return ExtCreateRegion(&tm, size, data);
}

///
enum class window_shape_operation {
	copy = 5,
	diff = 4,
	and = 1,
	or = 2,
	xor = 3,
};
dllg gml_id<window_shape> window_shape_combine(gml_id_destroy<window_shape> shape1, gml_id_destroy<window_shape> shape2, int op) {
	static_assert((int)window_shape_operation::copy == RGN_COPY);
	static_assert((int)window_shape_operation::diff == RGN_DIFF);
	static_assert((int)window_shape_operation::and  == RGN_AND);
	static_assert((int)window_shape_operation::or   == RGN_OR);
	static_assert((int)window_shape_operation::xor  == RGN_XOR);
	auto result = window_shape_create_empty();
	if (CombineRgn(result, shape1, shape2, op) == ERROR) {
		DeleteObject(result);
		result = (window_shape)0;
	}
	DeleteObject(shape1);
	DeleteObject(shape2);
	return result;
}
dllg gml_id<window_shape> window_shape_combine_nc(gml_id<window_shape> shape1, gml_id<window_shape> shape2, int op) {
	auto result = window_shape_create_empty();
	if (CombineRgn(result, shape1, shape2, op) == ERROR) {
		DeleteObject(result);
		result = (window_shape)-1;
	}
	return result;
}

dllg bool window_shape_concat(gml_id<window_shape> dest, gml_id<window_shape> shape, int op) {
	auto result = CombineRgn(dest, dest, shape, op) != ERROR;
	DeleteObject(shape);
	return result;
}
dllg bool window_shape_concat_nc(gml_id<window_shape> dest, gml_id<window_shape> shape, int op) {
	return CombineRgn(dest, dest, shape, op) != ERROR;
}

dllg bool window_shape_contains_point(gml_id<window_shape> shape, int x, int y) {
	return PtInRegion(shape, x, y);
}
dllg bool window_shape_contains_rectangle(gml_id<window_shape> shape, int x1, int y1, int x2, int y2) {
	RECT rect;
	rect.left = x1;
	rect.right = x2;
	rect.top = y1;
	rect.bottom = y2;
	return RectInRegion(shape, &rect);
}

static HWND hwnd;
const bool want_redraw = false; // redraws anyway? Go figure
dllg void window_shape_set(gml_id_destroy<window_shape> shape) {
	SetWindowRgn(hwnd, shape, want_redraw);
}
dllg void window_shape_set_nc(gml_id<window_shape> shape) {
	shape = window_shape_duplicate(shape);
	SetWindowRgn(hwnd, shape, want_redraw);
}
dllg void window_shape_reset() {
	SetWindowRgn(hwnd, NULL, want_redraw);
}
dllg void window_shape_destroy(gml_id_destroy<window_shape> shape) {
	DeleteObject(shape);
}

dllx void window_shape_init_raw(void* _hwnd) {
	hwnd = (HWND)_hwnd;
}

///
dllx void window_enable_per_pixel_alpha() {
	DWM_BLURBEHIND bb = { 0 };
	bb.dwFlags = DWM_BB_ENABLE | DWM_BB_BLURREGION;
	bb.hRgnBlur = CreateRectRgn(0, 0, -1, -1);
	bb.fEnable = TRUE;
	DwmEnableBlurBehindWindow(hwnd, &bb);
	// todo: WM_NCHITTEST?
}

static LONG GetWindowExStyle(HWND hwnd) {
	return GetWindowLong(hwnd, GWL_EXSTYLE);
}
static void SetWindowExStyle(HWND hwnd, LONG flags) {
	SetWindowLong(hwnd, GWL_EXSTYLE, (flags));
}
static bool GetWindowLayered(HWND hwnd) {
	return GetWindowExStyle(hwnd) & WS_EX_LAYERED;
}
static void SetWindowLayered(HWND hwnd, bool layered) {
	auto flags = GetWindowExStyle(hwnd);
	if (layered) {
		if ((flags & WS_EX_LAYERED) == 0) {
			SetWindowExStyle(hwnd, flags | WS_EX_LAYERED);
		}
	} else {
		if ((flags & WS_EX_LAYERED) != 0) {
			SetWindowExStyle(hwnd, flags & ~WS_EX_LAYERED);
		}
	}
}

///
dllx double window_get_alpha() {
	if (!GetWindowLayered(hwnd)) return 1;
	BYTE alpha = 0;
	DWORD flags = 0;
	GetLayeredWindowAttributes(hwnd, NULL, &alpha, &flags);
	if ((flags & LWA_ALPHA) == 0) return 1;
	return (double)alpha / 255;
}
///
dllx void window_set_alpha(double alpha) {
	bool set = alpha < 1;
	if (set) {
		SetWindowLayered(hwnd, true);
	} else {
		if (!GetWindowLayered(hwnd)) return;
	}
	//
	BYTE bAlpha = 0;
	COLORREF crKey = {};
	DWORD flags = 0;
	GetLayeredWindowAttributes(hwnd, &crKey, &bAlpha, &flags);
	//
	if (set) {
		flags |= LWA_ALPHA;
		if (alpha < 0) alpha = 0;
		bAlpha = (BYTE)(alpha * 255);
		SetLayeredWindowAttributes(hwnd, crKey, bAlpha, flags);
	} else {
		flags &= ~LWA_ALPHA;
		SetLayeredWindowAttributes(hwnd, crKey, 255, flags);
		if (flags == 0) SetWindowLayered(hwnd, false);
	}
}
///
dllx double window_get_chromakey() {
	if (!GetWindowLayered(hwnd)) return -1;
	COLORREF crKey;
	DWORD flags = 0;
	GetLayeredWindowAttributes(hwnd, &crKey, NULL, &flags);
	if ((flags & LWA_COLORKEY) == 0) return -1;
	return crKey;
}
///
dllx void window_set_chromakey(double color) {
	bool set = color >= 0;
	if (set) {
		SetWindowLayered(hwnd, true);
	} else {
		if (!GetWindowLayered(hwnd)) return;
	}
	//
	BYTE bAlpha = 0;
	COLORREF crKey = {};
	DWORD flags = 0;
	GetLayeredWindowAttributes(hwnd, &crKey, &bAlpha, &flags);
	//
	if (set) {
		flags |= LWA_COLORKEY;
		crKey = (DWORD)color;
		SetLayeredWindowAttributes(hwnd, crKey, bAlpha, flags);
	} else {
		flags &= ~LWA_COLORKEY;
		crKey = 0xFF00FF;
		SetLayeredWindowAttributes(hwnd, crKey, bAlpha, flags);
		if (flags == 0) SetWindowLayered(hwnd, false);
	}
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved) {
	if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
		hwnd = 0;
	}
	/*switch (ul_reason_for_call) {
		case DLL_PROCESS_ATTACH:
		case DLL_PROCESS_DETACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
	}*/
	return TRUE;
}
