/// @desc Draw mask cutouts (transparent)

gpu_set_blendmode_ext(bm_zero, bm_zero);

with (pMask) {
    if (id != other.id)
    mask.Draw();
}

gpu_set_blendmode(bm_normal);

with (pMask) {
    if (id != other.id)
    mask.DrawOutline();
}

gpu_set_blendmode_ext(bm_zero, bm_zero);

mask.Draw();

gpu_set_blendmode(bm_normal);
