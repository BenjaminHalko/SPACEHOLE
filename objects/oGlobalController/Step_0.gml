/// @desc Game Step

if (room == rInit) {
    exit;
}


// Window Height
if (!OPERA) {
    var _height = ceil((RES_WIDTH / window_get_width()) * window_get_height());
    
    if (_height != RES_HEIGHT) {
        RES_HEIGHT = _height;
        surface_resize(application_surface, RES_WIDTH, RES_HEIGHT);
        camera_set_view_size(view_camera[0], RES_WIDTH, RES_HEIGHT);
        oCamera.viewHeightHalf = RES_HEIGHT / 2;
    }
}

// Fullscreen
if (DESKTOP and (keyboard_check_pressed(vk_f4) or keyboard_check_pressed(vk_f11))) window_set_fullscreen(!window_get_fullscreen());
    
if (room != rMenu and keyboard_check_pressed(ord("R"))) {
    if (room == rGameEnd) {
        transition(lv1);
    } else if (instance_exists(oTransition) and oTransition.targetRoom == room) {
        oTransition.targetRoom = lv1;
    } else {
        transition(room);
    }
}

Input();
if (room != rMenu and keyBack) {
    transition(rMenu);
}
