if (room == rGameEnd) {
    oLeaderboardAPI.showAll = true;
    call_later(3, time_source_units_seconds, function() {
        if (instance_exists(id)) {
            FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path($"/lvAll/").Listener();
        }
    });
    scoreDisplay = global.gameScore;
} else {
    call_later(3, time_source_units_seconds, function() {
        if (instance_exists(id)) {
            FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path($"/lv{global.level}/").Listener();
        }
    });
    scoreDisplay = global.score;
}

ShowLeaderboard();
