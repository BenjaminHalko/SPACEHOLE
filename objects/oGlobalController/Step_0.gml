/// @desc Game Step

if (room == rInit) {
    exit;
}


// Window Height
var _height = ceil((RES_WIDTH / window_get_width()) * window_get_height());

if (_height != RES_HEIGHT) {
    RES_HEIGHT = _height;
    surface_resize(application_surface, RES_WIDTH, RES_HEIGHT);
    camera_set_view_size(view_camera[0], RES_WIDTH, RES_HEIGHT);
    oCamera.viewHeightHalf = RES_HEIGHT / 2;
}

// Fullscreen
if (DESKTOP and (keyboard_check_pressed(vk_f4) or keyboard_check_pressed(vk_f11))) window_set_fullscreen(!window_get_fullscreen());
    

if (!instance_exists(oMenu)) {
    if (keyboard_check_pressed(ord("R"))) {
    if (room == rMenu) room_goto(rMenu);
    else transition(room);
}

if (keyboard_check_pressed(ord("E"))) {
    global.username = "Jim2";
    FinishLevel();
}
}

Input();
if (room != rMenu and keyBack) {
    transition(rMenu);
}

if (keyboard_check_pressed(ord("B"))) {
    screen_save("save.png");
}
