/// @desc

scores = [];

draw = false;
scoreOffset = 0;
scoreOffsetTarget = 0;

scoresPerPage = 8;
disableSelect = false;
scrollSpd = 1;

moved = false;

global.highscore = 0;
global.gxGames = false;
global.userID = "";
global.noInternet = false;

LeaderboardGet();
//room_goto_next();
