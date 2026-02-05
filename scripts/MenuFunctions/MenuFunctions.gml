function FinishLevel() {
    global.gameState = GameState.END;
    
    LeaderboardPost(global.level);
    
    if (global.gameScore != -1 and global.level == global.maxLevels-1) {
        LeaderboardPost("All");
    }
    
    call_later(0.5, time_source_units_seconds, function() {
        audio_play_sound(snStart, 1, false);
        instance_create_layer(0, 0, "Global", oEndScreen);
    });
}

function GameStart() {
    global.gameScore = -1;
    global.level = 0;
    transition(asset_get_index($"lv{global.level + 1}"));
}
