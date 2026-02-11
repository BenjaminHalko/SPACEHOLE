if (room == rGameEnd) {
    oLeaderboardAPI.showAll = true;
    scoreDisplay = global.gameScore;
} else {
    scoreDisplay = global.score;
}

ShowLeaderboard();
