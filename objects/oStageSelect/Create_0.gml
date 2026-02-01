blink = 0;
start = false;
acceptMenuInput = true;
menuCursorY = 0;
option = 0;
oLeaderboardAPI.draw = true;
FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path("/lv0/").Listener();

global.level = 0;
