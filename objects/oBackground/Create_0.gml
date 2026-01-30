/// @desc Initialize shader uniforms

// Get uniform handles
u_time = shader_get_uniform(shBackground, "u_time");
u_camY = shader_get_uniform(shBackground, "u_camY");
u_resolution = shader_get_uniform(shBackground, "u_resolution");
u_parallaxStrength = shader_get_uniform(shBackground, "u_parallaxStrength");
u_colorPrimary = shader_get_uniform(shBackground, "u_colorPrimary");
u_colorSecondary = shader_get_uniform(shBackground, "u_colorSecondary");
u_colorTertiary = shader_get_uniform(shBackground, "u_colorTertiary");
u_noiseScale = shader_get_uniform(shBackground, "u_noiseScale");
u_flowSpeed = shader_get_uniform(shBackground, "u_flowSpeed");
u_starsEnabled = shader_get_uniform(shBackground, "u_starsEnabled");

// Customizable properties (edit these to change appearance)
parallaxStrength = 0.4;                // 0.0 = no parallax, 0.2 = strong parallax
colorPrimary = [0.6, 0.2, 0.8];        // Purple
colorSecondary = [0.2, 0.4, 0.9];      // Blue
colorTertiary = [0.9, 0.3, 0.2];       // Orange-red
noiseScale = 3.0;                      // Larger = more detailed/smaller patterns
flowSpeed = 0.8;                      // Animation speed multiplier
starsEnabled = true;                   // Toggle stars on/off
