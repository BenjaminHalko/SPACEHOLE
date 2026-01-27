/// @desc 

#macro RES_WIDTH 480
#macro RES_HEIGHT 270

randomize();

getOsType();

surface_resize(application_surface, RES_WIDTH, RES_HEIGHT);

if (DESKTOP) {
    window_shape_init();
    window_enable_per_pixel_alpha();
	window_enable_borderless_fullscreen(true);
	window_set_size(RES_WIDTH*3, RES_HEIGHT*3);
	window_center();
}

// Load Save Data
ini_open(SAVEFILE);
global.username = ini_read_string("settings","username","");
global.audioVol = ini_read_real("settings","vol",0.7);
global.pb =  ini_read_real("score","score",0);
ini_close();

if (string_length(global.username) > 10)
    global.username = "";

audio_master_gain(global.audioVol);

instance_create_layer(0,0,layer,oLeaderboardAPI);