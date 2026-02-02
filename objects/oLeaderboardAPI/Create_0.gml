/// @desc

scores = {
    "lvAll": []
};
for(var i = 0; i < global.maxLevels; i++) {
    scores[$ $"lv{i}"] = [];
}

draw = false;
scoreOffset = 0;
scoreOffsetTarget = 0;

scoresPerPage = 8;
disableSelect = false;
scrollSpd = 1;

moved = false;

global.gxGames = false;
global.userID = "";
global.noInternet = false;
global.level = -1;

LeaderboardGet();
