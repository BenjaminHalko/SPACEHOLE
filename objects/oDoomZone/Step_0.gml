/// @desc Update mask

mask.Update();

if (room == lv5) {
    mask.y -= 1;
    
    if (mask.y > oCamera.y + oCamera.viewHeightHalf + 100) {
        mask.y -= 3;
    }
    
    mask.y = max(mask.y, maxHeight);
}
