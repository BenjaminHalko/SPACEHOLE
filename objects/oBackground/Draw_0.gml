/// @desc Draw BG

var _camX = oCamera.x - oCamera.viewWidthHalf;
var _camY = oCamera.y - oCamera.viewHeightHalf;
var _mat_trf_rot_z = matrix_build(-_camX, -_camY, 0, 0, 0, 0, 1, 1, 1);
matrix_set(matrix_world, _mat_trf_rot_z);

surface_set_target(surface);
draw_clear(c_black);

with (oPlayer) {
    draw_set_colour(c_fuchsia);
    draw_primitive_begin(pr_trianglefan);
    
    draw_vertex(x, y);
    
    for(var i = 0; i <= sides; i++) {
        draw_vertex(
            x + lengthdir_x(radius, image_angle + 45 + i / sides * 360),
            y + lengthdir_y(radius, image_angle + 45 + i / sides * 360));
    }
    
    draw_primitive_end();
}

gpu_set_blendmode(bm_subtract);

with (oMaskEnemy) {
    mask.Draw();
}

gpu_set_blendmode(bm_normal);

with (oMaskEnemy) {
    mask.DrawOutline();
}

surface_reset_target();

matrix_set(matrix_world, matrix_build_identity());
draw_surface(surface, _camX, _camY);

