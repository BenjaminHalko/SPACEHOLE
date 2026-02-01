/// @desc 

Input();

if (keySelect) {
    if (global.level == global.maxLevels - 1) {
        transition(rMenu);
    } else {
        transition(asset_get_index($"lv{global.level+2}"));
    }
}
