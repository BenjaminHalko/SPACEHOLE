function FinishLevel() {
    global.gameState = GameState.END;
    show_debug_message(global.score);
    
    LeaderboardPost(global.level);
}
