/// @desc Draw


draw_set_color(c_white);
shader_set(shDissolve);
shader_set_uniform_f(global.uDissolve, animcurve_channel_evaluate(deathCurve, death));
shader_set_uniform_f(global.uDissolveCol, 1.0, 0.5, 0);
shader_set_uniform_f(global.uDissolveWidth, 0.08);

// draw_sprite_ext(sprite_index, image_index, x + 4, y + 4, image_xscale, image_yscale, image_angle, c_black, 0.5);
draw_self();

shader_set_uniform_f(global.uDissolve, animcurve_channel_evaluate(deathCurve, max(0, (death - 0.8) * 5)));
draw_circle(x, y, radius, true);

shader_reset();


if (swingTarget != noone) {
    lightning.Draw(
        x,
        y,
        swingTarget.x,
        swingTarget.y,
        4, 10, 0, 10, false);
}

