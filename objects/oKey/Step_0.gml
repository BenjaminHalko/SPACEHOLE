if (active) {
    image_alpha -= 0.1;
    image_angle -= 5;
    if (image_alpha <= 0) instance_destroy();
}