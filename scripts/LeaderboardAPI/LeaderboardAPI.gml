/// @desc Get the current leaderboards
function LeaderboardGet(_room=undefined) {
    if (!is_undefined(_room)) {
        _room = $"/lv{_room}/";   
    } else {
        _room = "/";
    }
    FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path(_room).Read();
}

/// @desc Post a score to the leaderboards
/// @param {struct} score
function LeaderboardPost(_level) {
    _level = $"lv{_level}";
    
	var _score = {
		name: global.username,
		points: _level == "lvAll" ? global.gameScore : global.score,
        userID: global.userID
	}
	
	if (_score.points < global.pb[$ _level] or global.pb[$ _level] <= 0) {
		global.pb[$ _level] = _score.points;
		if (!global.noInternet)
			Save("score", _level, _score.points);
	}
	with(oLeaderboardAPI) {
        var _scores = scores[$ _level];
		var _index = array_find_index(_scores, function(_val) {
            if (global.gxGames)
                return _val.userID == global.userID;
			return _val.name == global.username;
		});
		
		if _index == -1 or _scores[_index].points > _score.points {
			if (_index == -1) array_push(_scores, _score);
			else {
				_scores[_index].points = _score.points;
			}
			
			array_sort(_scores, function(_ele1,_ele2) {
				return (_ele1.points - _ele2.points)
			});
			
            FirebaseRealTime(FIREBASE_LEADERBOARD_URL).Path($"{_level}/{_score.name}").Set(json_stringify({
                points: _score.points
            }));
		}
	}
}
