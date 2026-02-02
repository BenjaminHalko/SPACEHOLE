/// @desc 

Input();

if (keySelect) {
    if (room == rGameEnd) {
        transition(rMenu);
    } else if (global.level == global.maxLevels - 1) {
        transition(global.gameScore == -1 ? rMenu : rGameEnd);
    } else {
        transition(asset_get_index($"lv{global.level+2}"));
    }
}
