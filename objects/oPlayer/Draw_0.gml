/// @desc Draw


var _x = x;
var _y = y;

if (death > 0.5) {
    _x += random_range(-2, 2) * max(0, death - 0.5) * 2;
    _y += random_range(-2, 2) * max(0, death - 0.5) * 2;
}

shader_set(shDissolve);
shader_set_uniform_f(global.uDissolve, death);
shader_set_uniform_f(global.uDissolveCol, 1.0, 0.5, 0);
shader_set_uniform_f(global.uDissolveWidth, 0.03);
shader_set_uniform_f(global.uDissolvePos, x, y);

draw_self();

shader_reset();


if (swingTarget != noone) {
    lightning.Draw(
        x,
        y,
        swingTarget.x,
        swingTarget.y,
        4, 10, 0, 10, false);
}

