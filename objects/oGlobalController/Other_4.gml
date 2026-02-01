/// @desc Set Level

var _name = room_get_name(room);
if (string_starts_with(_name, "lv")) {
    global.level = real(string_trim(_name, ["lv"]));
}
