if (!surface_exists(surface) or surHeight != RES_HEIGHT) {
    surface_free(surface);
    surface = surface_create(RES_WIDTH, RES_HEIGHT);
}

switch(phase) {
    case -1: {
        if (--wait <= 0) {
            introPercent = Approach(introPercent, 1, 0.012);
        }
        scaleTo = 0.7;
        if (introPercent == 1) {
            phase++;
            introPercent = 0;
            scaleTo = 1;
        }
    } break;
    case 0: {
        Input();
        if (keySelect) {
            if (MOBILE) {
                var _editName = (global.username == "");
                
                if (mouse_check_button_pressed(mb_left)) {
                    if (mouse_y < RES_HEIGHT * 0.2 + camera_get_view_y(view_camera[0])) {
                        _editName = true;   
                    }
                }
                
                if (editingUsername and !keyboard_check_pressed(vk_enter)) {
                    if (mouse_check_button_pressed(mb_left)) {
                        if (editingUsername) {
                            editingUsername = false;
                            Save("settings","username",global.username);
                        }
                        keyboard_virtual_hide();
                        
                    }
                } else if (_editName) {
                    editingUsername = true;
                    keyboard_string = global.username;
                    keyboard_lastkey = vk_nokey;
                    keyboard_virtual_show(
                        kbv_type_ascii,
                        kbv_returnkey_go,
                        kbv_autocapitalize_words,
                        true);
                } else {
                    if (editingUsername) {
                        editingUsername = false;
                        Save("settings","username",global.username);
                    }
                    keyboard_virtual_hide();
                    GameStart();
                }
            } else {
                phase++;
                phasePercent = 0;
                instance_create_layer(0, 0, layer, oMenu);
            }
        }
        
        if (MOBILE and editingUsername and keyboard_lastkey != vk_nokey) {
            if (keyboard_lastkey == vk_backspace or (ord(keyboard_lastchar) >= 32 and ord(keyboard_lastchar) <= 126)) and string_length(keyboard_string) <= 10 and (keyboard_lastkey != vk_space or string_length(global.username) > 0) {
                global.username = keyboard_string;
            }
            else keyboard_string = global.username;
            keyboard_lastkey = vk_nokey;
        }
        
        introPercent = ApproachEase(introPercent, 1, 0.1, 0.8);
        phasePercent = ApproachEase(phasePercent, !(instance_exists(oTransition)), 0.1, 0.8);
        xTo = ApproachEase(xTo, 0.5, 0.05, 0.7);
        yTo = ApproachEase(yTo, Wave(0.48, 0.52, 2, 0), 0.05, 0.7);
        scaleTo = ApproachEase(scaleTo, MOBILE ? min(1, RES_HEIGHT / RES_WIDTH) : 0.8, 0.2, 0.8);
    } break;
    case 1: {
        xTo = ApproachEase(xTo, 0.5, 0.05, 0.7);
        yTo = ApproachEase(yTo, Wave(0.48, 0.52, 2, 0), 0.05, 0.7);
        scaleTo = ApproachEase(scaleTo, 0.6, 0.2, 0.8);
    } break;
    case 2: {
        xTo = ApproachEase(xTo, 0.7, 0.05, 0.7);
        yTo = ApproachEase(yTo, Wave(0.49, 0.51, 2, 0) - 0.2, 0.05, 0.7);
        scaleTo = ApproachEase(scaleTo, 0.4, 0.2, 0.8);
    } break;
}

x = RES_WIDTH * xTo;
y = RES_HEIGHT * yTo;
image_xscale = scaleTo;
image_yscale = scaleTo;
