/// @desc Update mask

mask.Update();

// Optional: animate offsets for wobble effect (circles only)
if (variable_struct_exists(mask, "UpdateOffsets")) {
    mask.UpdateOffsets();
}
