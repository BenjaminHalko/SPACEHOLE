draw_set_colour(c_fuchsia);
draw_primitive_begin(pr_trianglefan);

draw_vertex(x, y);

for(var i = 0; i <= sides; i++) {
    draw_vertex(
        x + lengthdir_x(radius, image_angle + 45 + i / sides * 360),
        y + lengthdir_y(radius, image_angle + 45 + i / sides * 360));
}

draw_primitive_end();