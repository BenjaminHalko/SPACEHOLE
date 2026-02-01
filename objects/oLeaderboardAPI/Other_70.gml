/// @desc Get Scores

if (async_load[? "type"] == "FirebaseRealTime_Read" or async_load[? "type"] == "FirebaseRealTime_Listener") {
    show_debug_message("HELLO");
    if (async_load[? "status"] == 200) {
        var _parseData = function(_value, _level) {
			var _names = variable_struct_get_names(_value);
            var _scores = [];
            scores[$ _level] = _scores;
		
			for(var i = 0; i < array_length(_names); i++) {
				try {
					var _scoreData = variable_struct_get(_value, _names[i]);
					_scores[i] = {
						name: _names[i],
						points: _scoreData.points,
					}
				} catch(_error) {
					_scores[i] = {
						name: _names[i],
						points: 0,
					}
				}
			}
			
			array_sort(_scores, function(_ele1,_ele2){
				return (_ele1.points - _ele2.points)
			});
			
            //if (!moved)
                //PositionLeaderboard();
        }
        
        var _path = async_load[? "path"];
		var _data = async_load[? "value"];
		if !is_undefined(_data) {
            var _value = json_parse(_data);
            if (_path == "") {
                var _names = struct_get_names(_value);
                for(var i = 0; i < array_length(_names); i++) {
                    _parseData(_value[$ _names[i]], _names[i]);
                }
            } else {
                _parseData(_value, _path);
            }
		}
	}
} else if (async_load[? "type"] == "FirebaseRealTime_Set") {
    var _path = async_load[? "path"];
    _path = string_copy(_path, 1, string_pos("/", _path) - 1);
    LeaderboardGet(_path);
}
