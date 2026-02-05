if (!surface_exists(surface) or surHeight != RES_HEIGHT) {
    surface_free(surface);
    surface = surface_create(RES_WIDTH, RES_HEIGHT);
}

switch(phase) {
    case -1: {
        if (--wait <= 0) {
            introPercent = Approach(introPercent, 1, 0.012);
        }
        scaleTo = 0.7;
        if (introPercent == 1) {
            phase++;
            introPercent = 0;
            scaleTo = 1;
        }
    } break;
    case 0: {
        Input();
        if (keySelect) {
            if (MOBILE) {
                GameStart();
            } else {
                phase++;
                phasePercent = 0;
                instance_create_layer(0, 0, layer, oMenu);
            }
        }
        introPercent = ApproachEase(introPercent, 1, 0.1, 0.8);
        phasePercent = ApproachEase(phasePercent, 1, 0.1, 0.8);
        xTo = ApproachEase(xTo, 0.5, 0.05, 0.7);
        yTo = ApproachEase(yTo, Wave(0.48, 0.52, 2, 0), 0.05, 0.7);
        scaleTo = ApproachEase(scaleTo, 0.8, 0.2, 0.8);
    } break;
    case 1: {
        xTo = ApproachEase(xTo, 0.5, 0.05, 0.7);
        yTo = ApproachEase(yTo, Wave(0.48, 0.52, 2, 0) - 0.2, 0.05, 0.7);
        scaleTo = ApproachEase(scaleTo, 0.6, 0.2, 0.8);
    } break;
    case 2: {
        xTo = ApproachEase(xTo, 0.7, 0.05, 0.7);
        yTo = ApproachEase(yTo, Wave(0.49, 0.51, 2, 0) - 0.2, 0.05, 0.7);
        scaleTo = ApproachEase(scaleTo, 0.4, 0.2, 0.8);
    } break;
}

x = RES_WIDTH * xTo;
y = RES_HEIGHT * yTo;
image_xscale = scaleTo;
image_yscale = scaleTo;
