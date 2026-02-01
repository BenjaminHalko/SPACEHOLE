menuCursorY = ApproachEase(menuCursorY, 32 * global.level, 28, 0.8);

if (start) {
    if (alarm[0] <= 0) alarm[0] = 5;
    if (blink >= 8) transition(asset_get_index($"lv{global.level + 1}"));
    exit;
}

Input();

if (keyBack) {
    oLogo.phase--;
    instance_create_layer(0, 0, layer, oMenu);
    instance_destroy();
}

if (keyLeft or keyRight) {
    if (acceptMenuInput) {
        global.level = Wrap(global.level + keyRight - keyLeft, 0, global.maxLevels - 1);
        acceptMenuInput = false;
        audio_play_sound(snBlip,2,false);
    }
} else {
    acceptMenuInput	= true;	
}

if (keySelect) {
    start = true;
    audio_play_sound(snStart, 2, false);
}
