//
// Animated space/aurora background shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform float u_camY;
uniform vec2 u_resolution;
uniform float u_parallaxStrength;
uniform vec3 u_colorPrimary;
uniform vec3 u_colorSecondary;
uniform vec3 u_colorTertiary;
uniform float u_noiseScale;
uniform float u_flowSpeed;
uniform float u_starsEnabled;

// Hash function for pseudo-random values
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// 2D noise function
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Smooth interpolation
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Four corners
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Fractional Brownian Motion - layered noise for cloud-like effect
float fbm(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < 6; i++) {
        if (i >= octaves) break;
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

// Star field
float stars(vec2 uv, float time) {
    vec2 gridPos = floor(uv * 50.0);
    vec2 gridUV = fract(uv * 50.0) - 0.5;

    float starRandom = hash(gridPos);

    // Only some cells have stars
    if (starRandom > 0.97) {
        // Each star has a different flicker speed (slow with high variance)
        float twinkleSpeed = 0.08 + starRandom * 0.32;

        // Cycle determines both phase and twinkle - they're synced
        float cycle = time * twinkleSpeed + starRandom * 10.0;
        float phase = floor(cycle);

        // Twinkle: sin over the cycle, 0 at start/end, 1 in middle
        // Position only changes when twinkle = 0 (at phase boundaries)
        float twinkle = sin(fract(cycle) * 3.14159);

        // Star position within cell (changes each phase, but only visible after twinkle = 0)
        vec2 starPos = vec2(
            hash(gridPos + vec2(phase * 0.17, phase * 0.31)),
            hash(gridPos + vec2(phase * 0.23, phase * 0.13))
        ) - 0.5;
        float dist = length(gridUV - starPos * 0.8);

        // Star brightness based on distance
        float brightness = smoothstep(0.05, 0.0, dist) * twinkle * (0.6 + starRandom * 0.4);

        return brightness;
    }

    return 0.0;
}

void main() {
    // Normalized coordinates
    vec2 uv = gl_FragCoord.xy / u_resolution;

    // Parallax offset based on camera Y
    float parallaxOffset = u_camY * u_parallaxStrength * 0.001;

    // Time-based animation
    float time = u_time * u_flowSpeed;

    // Multiple noise layers with different parallax depths
    vec2 uv1 = uv * u_noiseScale + vec2(time * 0.1, parallaxOffset * 1.0);
    vec2 uv2 = uv * u_noiseScale * 0.7 + vec2(-time * 0.05, parallaxOffset * 1.6);
    vec2 uv3 = uv * u_noiseScale * 1.3 + vec2(time * 0.08, parallaxOffset * 2.4);

    // Generate noise layers
    float noise1 = fbm(uv1, 5);
    float noise2 = fbm(uv2, 4);
    float noise3 = fbm(uv3, 3);

    // Combine noise for color mixing
    float colorMix1 = smoothstep(0.3, 0.7, noise1);
    float colorMix2 = smoothstep(0.4, 0.6, noise2);
    float colorMix3 = smoothstep(0.35, 0.65, noise3);

    // Base dark space color
    vec3 spaceColor = vec3(0.02, 0.02, 0.05);

    // Blend accent colors based on noise
    vec3 color = spaceColor;
    color = mix(color, u_colorPrimary * 0.4, colorMix1 * 0.5);
    color = mix(color, u_colorSecondary * 0.35, colorMix2 * 0.4);
    color = mix(color, u_colorTertiary * 0.3, colorMix3 * 0.3);

    // Add some brightness variation
    float brightness = fbm(uv * 2.0 + vec2(time * 0.02, parallaxOffset * 0.6), 3);
    color += color * brightness * 0.5;

    // Aurora-like flowing bands
    float aurora = sin(uv.y * 10.0 + noise1 * 5.0 + time) * 0.5 + 0.5;
    aurora *= smoothstep(0.3, 0.5, noise2) * 0.3;
    color += mix(u_colorPrimary, u_colorSecondary, noise3) * aurora * 0.2;

    // Stars layer (fixed position, only twinkle based on time)
    if (u_starsEnabled > 0.5) {
        float starField = stars(uv, u_time);
        color += vec3(starField);
    }

    // Subtle vignette for depth
    float vignette = 1.0 - length((uv - 0.5) * 1.2) * 0.3;
    color *= vignette;

    // Ensure we don't exceed valid color range
    color = clamp(color, 0.0, 1.0);

    gl_FragColor = vec4(color, 1.0);
}
