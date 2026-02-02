/// @desc 

#macro RES_WIDTH 480
#macro RES_HEIGHT global.windowHeight

enum GameState {
    NORMAL,
    END,
    DEATH,
    ROOM_TRANSITION
}

randomize();

RES_HEIGHT = RES_WIDTH * 0.75;

getOsType();

surface_resize(application_surface, RES_WIDTH, RES_HEIGHT);

if (DESKTOP) {
    window_shape_init();
    window_enable_per_pixel_alpha();
	window_enable_borderless_fullscreen(true);
	window_set_size(RES_WIDTH*3, RES_HEIGHT*3);
	window_center();
}

// Load Shaders
global.uDissolve = shader_get_uniform(shDissolve, "u_dissolve");
global.uDissolveCol = shader_get_uniform(shDissolve, "u_edgeColor");
global.uDissolveWidth = shader_get_uniform(shDissolve, "u_edgeWidth");
global.uPlanetTime = shader_get_uniform(shPlanet, "iTime");
global.uPlanetResolution = shader_get_uniform(shPlanet, "iResolution");
global.uPlanetDissolve = shader_get_uniform(shPlanet, "u_dissolve");
global.uPlanetCol = shader_get_uniform(shPlanet, "u_edgeColor");
global.uPlanetWidth = shader_get_uniform(shPlanet, "u_edgeWidth");
global.uPlanetPos = shader_get_uniform(shPlanet, "u_planetPos");
global.uPlanetColorA = shader_get_uniform(shPlanet, "u_colorA");
global.uPlanetColorB = shader_get_uniform(shPlanet, "u_colorB");

// Game State
global.gameState = GameState.NORMAL;
global.gameScore = 0;
global.score = 0;
global.planetCount = 0;

// Levels
global.levelNames = [
    "1: ORBIT",
    "2: LAUNCH",
    "3: GLIDE",
    "4: ACCESS",
    "X: SPACEHOLE"
];
global.maxLevels = array_length(global.levelNames);

// Load Save Data
ini_open(SAVEFILE);
global.username = ini_read_string("settings","username","");
global.audioVol = ini_read_real("settings","vol",0.7);
global.pb = {
    "lvAll": ini_read_real("score", "lvAll", 0)
};
for(var i = 0; i < global.maxLevels; i++) {
    var _level = $"lv{i}";
    global.pb[$ _level] = ini_read_real("score", _level, 0);
}
ini_close();

if (string_length(global.username) > 10)
    global.username = "";

audio_master_gain(global.audioVol);

instance_create_layer(0,0,layer,oLeaderboardAPI);

audio_play_sound(mMusic, 1, true, 1, 4.8);

room_goto_next();
