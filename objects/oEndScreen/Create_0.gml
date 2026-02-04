if (room == rGameEnd) {
    oLeaderboardAPI.showAll = true;
    FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path($"/lvAll/").Listener();
    scoreDisplay = global.gameScore;
} else {
    FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path($"/lv{global.level}/").Listener();
    scoreDisplay = global.score;
}

ShowLeaderboard();
