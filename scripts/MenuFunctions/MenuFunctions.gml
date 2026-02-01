function FinishLevel() {
    global.gameState = GameState.END;
    
    LeaderboardPost(global.level);
    
    call_later(0.5, time_source_units_seconds, function() {
       instance_create_layer(0, 0, "Global", oEndScreen);
    });
}

function SetLevel(_level) {
    if (_level == global.level) return;
    global.level = _level;

    FirebaseRealTime(FIREBASE_LEADERBOARD_URL).ListenerRemoveAll();
    
    if (global.level == -1) return;
    FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path($"/lv{global.level}/").Listener();
}
