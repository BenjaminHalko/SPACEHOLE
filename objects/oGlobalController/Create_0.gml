/// @desc 

#macro RES_WIDTH 256
#macro RES_HEIGHT 224

randomize();

getOsType();

surface_resize(application_surface, RES_WIDTH, RES_HEIGHT);

if (DESKTOP) {
	window_enable_borderless_fullscreen(true);
	window_set_size(256*3, 224*3);
	window_center();
}

// Load Save Data
ini_open(SAVEFILE);
global.username = ini_read_string("settings","username","");
global.audioVol = ini_read_real("settings","vol",0.7);
global.pb =  ini_read_real("score","score",0);
global.render = ini_read_real("settings","render",true);
ini_close();

if (string_length(global.username) > 10)
    global.username = "";

audio_master_gain(global.audioVol);

instance_create_layer(0,0,layer,oLeaderboardAPI);