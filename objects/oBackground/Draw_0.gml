/// @desc Draw BG

surface_set_target(surface);
draw_clear(c_white);

gpu_set_blendmode(bm_subtract);

draw_circle(mouse_x, mouse_y, 30, false);

gpu_set_blendmode(bm_normal);

surface_reset_target();

draw_surface(surface, 0, 0);
