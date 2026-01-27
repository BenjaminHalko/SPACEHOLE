
draw_set_colour(c_fuchsia);
draw_primitive_begin(pr_linestrip);

for(var i = 0; i <= sides; i++) {
    draw_vertex(
        x + lengthdir_x(radius, image_angle + 45 + i / sides * 360),
        y + lengthdir_y(radius, image_angle + 45 + i / sides * 360));
}

draw_primitive_end();


if (swinging) {
    lightning.Draw(
        x,
        y,
        swingTarget.x,
        swingTarget.y,
        4, 10, 0, 10, false);
}

