if (room == rGameEnd) {
    oLeaderboardAPI.showAll = true;
    FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path($"/lvAll/").Listener();
} else {
    FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path($"/lv{global.level}/").Listener();
}

ShowLeaderboard();
