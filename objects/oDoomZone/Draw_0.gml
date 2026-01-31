/// @desc Draw mask cutouts (transparent)

gpu_set_blendmode_ext(bm_zero, bm_zero);

with (pMask) {
    mask.Draw();
}

gpu_set_blendmode(bm_normal);
