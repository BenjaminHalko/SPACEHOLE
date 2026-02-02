/// @desc Draw

shader_set(shDissolve);

shader_set_uniform_f(global.uDissolveCol, 1.0, 0.5, 0);
shader_set_uniform_f(global.uDissolveWidth, 0.08);

shader_set_uniform_f(global.uDissolve, animcurve_channel_evaluate(deathCurve, max(0, (death - 0.8) * 5)));
draw_sprite_ext(sprite_index, 1, x, y, image_xscale, image_yscale, image_angle, c_white, 1);

shader_set_uniform_f(global.uDissolve, animcurve_channel_evaluate(deathCurve, death));
draw_self();

shader_reset();


if (swingTarget != noone) {
    draw_set_colour(c_lime);
    lightning.Draw(
        x,
        y,
        swingTarget.x,
        swingTarget.y,
        4, 10, 0, 10, false);
}

