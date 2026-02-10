/// @desc Draw mask cutouts (transparent)

var _doom = id;

// Subtract all other mask shapes (cutouts)
gpu_set_blendmode_ext(bm_zero, bm_zero);
with (pMask) {
    if (id != _doom)
    mask.Draw();
}
gpu_set_blendmode(bm_normal);

// Build stencil: count overlapping masks per pixel
gpu_set_stencil_enable(true);
gpu_set_stencil_func(cmpfunc_always);
gpu_set_stencil_ref(0);
gpu_set_stencil_pass(stencilop_incr);
gpu_set_stencil_fail(stencilop_keep);
gpu_set_stencil_depth_fail(stencilop_keep);
gpu_set_colorwriteenable(false, false, false, false);

with (pMask) {
    mask.Draw();
}

// Per mask: remove self from stencil, draw outline where stencil==0, restore
draw_set_colour(c_lime);
with (pMask) {
    if (id == _doom) continue;

    // Decrement own mask from stencil
    gpu_set_stencil_func(cmpfunc_always);
    gpu_set_stencil_pass(stencilop_decr);
    gpu_set_colorwriteenable(false, false, false, false);
    mask.Draw();

    // Draw outline only where no other mask covers this pixel
    gpu_set_stencil_func(cmpfunc_equal);
    gpu_set_stencil_ref(0);
    gpu_set_stencil_pass(stencilop_keep);
    gpu_set_colorwriteenable(true, true, true, true);
    mask.DrawOutline();

    // Restore: increment own mask back
    gpu_set_stencil_func(cmpfunc_always);
    gpu_set_stencil_pass(stencilop_incr);
    gpu_set_colorwriteenable(false, false, false, false);
    mask.Draw();
}

gpu_set_stencil_enable(false);
gpu_set_colorwriteenable(true, true, true, true);

// Subtract oDoomZone's own mask
gpu_set_blendmode_ext(bm_zero, bm_zero);
mask.Draw();
gpu_set_blendmode(bm_normal);
