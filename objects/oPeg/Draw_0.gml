/// @desc Draw

draw_sprite_ext(sprite_index, image_index, x, y, scale, scale, 0, c_white, 1);

if (deactive > 0.5) {
    var _radius = lerp(4, 20, animcurve_channel_evaluate(bounceCurve, deactive));
    draw_circle(x, y, _radius, true);
}
