/// @desc Generate Levels

while (min(oCamera.y, oPlayer.y) - RES_HEIGHT < generationHeight) {
    var _level = levels[irandom(array_length(levels) - 1)];
    GenerateLevel(_level, (levelsGenerated mod 2 == 1));
}
