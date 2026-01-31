/// @desc Setup Generator

// Config
levels = RoomLoader.DataInitPrefix("lv");

// State
loadedLevels = [];
levelsGenerated = 0;
generationHeight = room_height;

/// @param {Asset.GMRoom} level
/// @param {bool} flipped
GenerateLevel = function(_level, _flipped) {
    // Clean up old levels
    while(array_length(loadedLevels) > 0) {
        if (loadedLevels[0][0] > oDoomZone.mask.y + 64) {
            loadedLevels[0][1].Cleanup(false);
            array_delete(loadedLevels, 0, 1);
        } else {
            break;
        }
    }
    
    // Get Info
    generationHeight -= RoomLoader.DataGetHeight(_level);
    levelsGenerated++;
    
    // Cleanup
    var _payload = RoomLoader.Mirror(_flipped).Load(_level, RES_WIDTH / 2, generationHeight);
    array_push(loadedLevels, [generationHeight, _payload]);
};


GenerateLevel(lvIntro, false);
