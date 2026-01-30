/// @desc Draw Background

var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);

shader_set(shBackground);

// Pass uniforms
shader_set_uniform_f(u_time, current_time / 1000);
shader_set_uniform_f(u_camY, _camY);
shader_set_uniform_f(u_resolution, RES_WIDTH, RES_HEIGHT);
shader_set_uniform_f(u_parallaxStrength, parallaxStrength);
shader_set_uniform_f(u_colorPrimary, colorPrimary[0], colorPrimary[1], colorPrimary[2]);
shader_set_uniform_f(u_colorSecondary, colorSecondary[0], colorSecondary[1], colorSecondary[2]);
shader_set_uniform_f(u_colorTertiary, colorTertiary[0], colorTertiary[1], colorTertiary[2]);
shader_set_uniform_f(u_noiseScale, noiseScale);
shader_set_uniform_f(u_flowSpeed, flowSpeed);
shader_set_uniform_f(u_starsEnabled, starsEnabled ? 1.0 : 0.0);

draw_rectangle(_camX, _camY, _camX + RES_WIDTH, _camY + RES_HEIGHT, false);

shader_reset();
