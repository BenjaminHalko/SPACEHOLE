// Inherit the parent event
event_inherited();

if (active) {
    image_xscale = ApproachEase(image_xscale, 0, 2, 0.8);
    if (image_xscale < 0) {
        instance_destroy();
    }
}
