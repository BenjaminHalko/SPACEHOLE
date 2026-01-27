
draw_set_colour(c_fuchsia);
draw_primitive_begin(pr_linestrip);

for(var i = 0; i < 5; i++) {
    draw_point(
        x + lengthdir_x(radius, image_angle + 45 + i * 90),
        y + lengthdir_y(radius, image_angle + 45 + i * 90));
}

draw_primitive_end();