/// @desc 

transitionPercent = 0;
transitionSpd = 0.05;
leading = true;

mask = new MaskEndZone();
mask.x = 0;
mask.y = room_height * 2;

global.gameState = GameState.ROOM_TRANSITION;
