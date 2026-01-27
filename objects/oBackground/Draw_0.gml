/// @desc Draw BG

surface_set_target(surface);
draw_clear(c_black);
gpu_set_blendmode(bm_subtract);

with (oMaskEnemy) {
    mask.Draw();
}

//with (oPlayer) {
    //draw_set_colour(c_blue);
    //draw_primitive_begin(pr_trianglestrip);
    //
    //for(var i = 0; i < 4; i++) {
        //draw_point(
            //x + lengthdir_x(radius, image_angle + 45 + i * 90),
            //y + lengthdir_y(radius, image_angle + 45 + i * 90));
    //}
    //
    //draw_primitive_end();
//}

gpu_set_blendmode(bm_normal);

with (oMaskEnemy) {
    mask.DrawOutline();
}

surface_reset_target();
draw_surface(surface, 0, 0);
