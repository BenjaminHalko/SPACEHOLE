/// @desc Update mask

mask.Update();

// Optional: animate offsets for wobble effect (circles only)
if (variable_struct_exists(mask, "UpdateOffsets")) {
    mask.UpdateOffsets();
}

// Update mask surface dimensions if resolution changed
maskWidth = RES_WIDTH;
maskHeight = RES_HEIGHT;

// Recreate surface if needed
if (!surface_exists(maskSurface)) {
    maskSurface = surface_create(maskWidth, maskHeight);
}


