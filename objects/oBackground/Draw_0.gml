/// @desc Draw BG

surface_set_target(surface);
draw_clear(c_black);
gpu_set_blendmode(bm_subtract);

with (oMaskEnemy) {
    mask.Draw();
}

gpu_set_blendmode(bm_normal);

with (oMaskEnemy) {
    mask.DrawOutline();
}

surface_reset_target();
draw_surface(surface, 0, 0);
