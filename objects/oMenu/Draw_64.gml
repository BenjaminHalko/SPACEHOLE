/// @desc 

draw_set_font(fSpace);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _menuScale = 1;

var _menuX = RES_WIDTH/2 - 34;
var _menuY = RES_HEIGHT/2 + 10;
draw_text_transformed(_menuX - 32, _menuY + menuCursorY, ">", _menuScale, _menuScale, Wave(-2, 2, 2, 0));
draw_text_transformed(_menuX, _menuY, "START", _menuScale, _menuScale, 4.5);

_menuScale *= 0.8;

if (!global.gxGames) {
    _menuY += 48;
    draw_set_color(merge_color(c_white, c_red, usernameFlash));
    draw_text_transformed(_menuX+random_range(-2,2)*usernameFlash, _menuY+random_range(-2,2)*usernameFlash, "USERNAME", _menuScale, _menuScale, 4.5);
    draw_set_color(c_white);
    
    _menuY += 28;
    var _username = global.username;
    if (blink and option == 1) _username += "_";
    if (global.username == "") {
        draw_set_color(c_dkgray);
        draw_text_transformed(_menuX+32, _menuY, "ENTER USERNAME", _menuScale * 0.6, _menuScale * 0.6, 4.5);
        draw_set_color(c_white);
    }
    draw_text_transformed(_menuX + 32, _menuY, _username, _menuScale * 0.6, _menuScale*0.6, 4.5);
}

_menuY += 40;
draw_sprite(sAudioLine,0,_menuX,_menuY);
draw_sprite(sAudioLine,1,_menuX+round(60 * global.audioVol),_menuY);
draw_sprite(sAudio,0,_menuX+62,_menuY);
