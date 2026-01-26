/// @desc 

if (!oLeaderboardAPI.draw) {
	Input();
	if(disableSelect) {
		keySelect = false;
		disableSelect = false;
	}
	if (DESKTOP or BROWSER or OPERA) {
		if (keyDown or keyUp) and (option != 2 or (!keyboard_check(ord("W")) and !keyboard_check(ord("S")))) {
			if (acceptMenuInput) {
				if (option == 2) {
					var _usernameLength = string_length(global.username);
					while(_usernameLength > 0 and string_char_at(global.username, _usernameLength) == " ") {
						global.username = string_copy(global.username,0,_usernameLength-1);
						_usernameLength = string_length(global.username);
					}
					
                    if (!global.gxGames and !global.noInternet)
					   Save("settings","username",global.username);
				}
				option = Wrap(option + keyDown - keyUp, 0, 3 - global.gxGames);
				if (option == 2) keyboard_string = global.username;
				acceptMenuInput = false;
				audio_play_sound(snBlip,2,false);
			}
		} else {
			acceptMenuInput	= true;	
		}
			
		if (option == 0 and keySelect) {
			if (global.username != "") {
				with(oMusicController) {
					if !audio_is_playing(music) {
						music = audio_play_sound(mMusic, 1, true);
					}
				}
				if (global.noInternet) {
					global.pb = 0;	
				}
				oGUI.alarm[0] = 1;
				audio_play_sound(snStart,2,false);
                instance_destroy();
			} else {
				usernameFlash = 1;
				audio_play_sound(snBlip,2,false);
			}
		}
		
		if (option == 1 and keySelect) {
			GotoLeaderboard();
			audio_play_sound(snBlip,2,false);
		}
	
		if (option == 2 and !global.gxGames) {
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
	
		if (option == (global.gxGames ? 2 : 3)) {
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
}