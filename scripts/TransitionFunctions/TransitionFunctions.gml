/// @desc Transitions to another room
/// @param {Asset.GMRoom} room
function transition(_room) {
	if (!instance_exists(oTransition)) {
		instance_create_depth(0,0,-9000,oTransition,{
			targetRoom: _room
		});	
	}
}