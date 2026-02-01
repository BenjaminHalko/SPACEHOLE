function FinishLevel() {
    global.gameState = GameState.END;
    
    // LeaderboardPost(global.level);
    
    call_later(0.5, time_source_units_seconds, function() {
       instance_create_layer(0, 0, "Global", oEndScreen);
    });
}
