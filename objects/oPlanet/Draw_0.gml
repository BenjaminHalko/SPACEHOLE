draw_set_color(c_white);
mask.DrawOutline();

var _camY = camera_get_view_y(view_camera[0]);
shader_set(shPlanet);
shader_set_uniform_f(global.uPlanetTime, current_time / 1000);
shader_set_uniform_f(global.uPlanetResolution, RES_WIDTH/2, RES_HEIGHT/2);
shader_set_uniform_f_array(global.uPlanetCol, colorDissolve);
shader_set_uniform_f(global.uPlanetWidth, 0.08);
shader_set_uniform_f(global.uPlanetDissolve, animcurve_channel_evaluate(deathCurve, death));
shader_set_uniform_f(global.uPlanetPos, 0, -_camY);
shader_set_uniform_f(global.uPlanetColorA, colorA[0], colorA[1], colorA[2]);
shader_set_uniform_f(global.uPlanetColorB, colorB[0], colorB[1], colorB[2]);
var _sides = 20;
draw_primitive_begin(pr_trianglestrip);
for(var i = 0; i < _sides; i++) {
    draw_vertex_texture(x, y, 0.5, 0.5);
    draw_vertex_texture(
        x + lengthdir_x(radius, i / _sides * 360),
        y + lengthdir_y(radius, i / _sides * 360),
        0.5 + lengthdir_x(radius, i / _sides * 360) / RES_WIDTH,
        0.5 + lengthdir_y(radius, i / _sides * 360) / RES_HEIGHT
    );
    draw_vertex_texture(
        x + lengthdir_x(radius, (i + 1) / _sides * 360),
        y + lengthdir_y(radius, (i + 1) / _sides * 360),
        0.5 + lengthdir_x(radius, (i + 1) / _sides * 360) / RES_WIDTH,
        0.5 + lengthdir_y(radius, (i + 1) / _sides * 360) / RES_HEIGHT
    );
}
draw_primitive_end();
shader_reset();

shader_set(shDissolve);
shader_set_uniform_f_array(global.uDissolveCol, colorDissolve);
shader_set_uniform_f(global.uDissolveWidth, 0.08);
shader_set_uniform_f(global.uDissolve, animcurve_channel_evaluate(deathCurve, death));
draw_circle(x, y, radius, true);
shader_reset();
