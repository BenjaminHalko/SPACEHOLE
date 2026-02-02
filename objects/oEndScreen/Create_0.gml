ShowLeaderboard();
FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path($"/lv{global.level}/").Listener();