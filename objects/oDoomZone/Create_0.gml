/// @desc Create Black Hole

mask = new MaskEndZone();
mask.x = 0;
mask.y = 400;

// Mask surface for shader
maskSurface = -1;
maskWidth = RES_WIDTH;
maskHeight = RES_HEIGHT;

// Cache shader uniforms
uMaskTexture = shader_get_sampler_index(shBlackHole, "u_mask");
