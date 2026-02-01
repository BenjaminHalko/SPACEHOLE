/// @desc 


Input();
if (keyBack and option != 1) {
    oLogo.phase--;
    instance_destroy();
}
if (DESKTOP or BROWSER or OPERA) {
    if (keyDown or keyUp) and (option != 1 or (!keyboard_check(ord("W")) and !keyboard_check(ord("S")))) {
        if (acceptMenuInput) {
            if (option == 1) {
                var _usernameLength = string_length(global.username);
                while(_usernameLength > 0 and string_char_at(global.username, _usernameLength) == " ") {
                    global.username = string_copy(global.username,0,_usernameLength-1);
                    _usernameLength = string_length(global.username);
                }
                
                if (!global.gxGames and !global.noInternet)
                Save("settings","username",global.username);
            }
            option = Wrap(option + keyDown - keyUp, 0, 2 - global.gxGames);
            if (option == 1) keyboard_string = global.username;
            acceptMenuInput = false;
            audio_play_sound(snBlip,2,false);
        }
    } else {
        acceptMenuInput	= true;	
    }
        
    if (option < 2 and keySelect) {
        if (global.username != "") {
            if (global.noInternet) {
                global.pb = 0;	
            }
            oLogo.phase++;
            instance_create_layer(0, 0, layer, oStageSelect);
            instance_destroy();
        } else {
            usernameFlash = 1;
            audio_play_sound(snBlip,2,false);
        }
    }

    if (option == 1 and !global.gxGames) {
        if (alarm[0] <= 0) alarm[0] = 30;
        if (keyboard_lastkey == vk_backspace or (ord(keyboard_lastchar) >= 32 and ord(keyboard_lastchar) <= 255)) and string_length(keyboard_string) <= 10 and (keyboard_lastkey != vk_space or string_length(global.username) > 0) {
            if (OPERA and string_length(keyboard_string) > string_length(global.username)) {
                var _char = string_char_at(keyboard_string, string_length(keyboard_string));
                if (keyboard_check(vk_shift))
                    _char = string_upper(_char);
                else
                    _char = string_lower(_char);
                keyboard_string = string_copy(keyboard_string, 1, string_length(keyboard_string)-1) + _char;
            }
            global.username = keyboard_string;
        }
        else keyboard_string = global.username;
        keyboard_lastkey = vk_nokey;
    }

    if (option == (global.gxGames ? 1 :2)) {
        if (keyLeft or keyRight) {
            if (volAcceptMenuInput) {
                volAcceptMenuInput = false;
                global.audioVol = clamp(global.audioVol + (keyRight - keyLeft) * 0.1, 0, 1);
                Save("settings","vol",global.audioVol);
                audio_master_gain(global.audioVol);
                audio_play_sound(snBlip,2,false);
            }
        } else {
            volAcceptMenuInput = true;	
        }
    }
}

usernameFlash = Approach(usernameFlash, 0, 0.04);

menuCursorY = ApproachEase(menuCursorY, 48 * option, 40, 0.8);
