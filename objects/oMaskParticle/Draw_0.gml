/// @desc 

draw_set_color(image_blend);

draw_triangle(
    x + lengthdir_x(radius * percent, image_angle),
    y + lengthdir_y(radius * percent, image_angle),
    x + lengthdir_x(radius * percent, image_angle+120),
    y + lengthdir_y(radius * percent, image_angle+120),
    x + lengthdir_x(radius * percent, image_angle+240),
    y + lengthdir_y(radius * percent, image_angle+240),
    false
);