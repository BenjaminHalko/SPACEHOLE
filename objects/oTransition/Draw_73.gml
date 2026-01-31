/// @desc 

gpu_set_blendmode_ext(bm_zero, bm_zero);
if (transitionPercent > 0.9) {
    var _camY = camera_get_view_y(view_camera[0]);
    draw_rectangle(0,_camY,RES_WIDTH,_camY+RES_HEIGHT,false);
} else {
    mask.Draw();
}

gpu_set_blendmode(bm_normal);
