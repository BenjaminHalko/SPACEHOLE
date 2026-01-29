//
// Dissolve fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_dissolve;      // 0.0 = fully visible, 1.0 = fully dissolved
uniform vec3 u_edgeColor;      // Color of the dissolve edge glow
uniform float u_edgeWidth;     // Width of the edge glow (0.0 - 0.1 works well)
uniform vec2 u_position;       // Object position for relative noise                                                                                                                                                                      

// Simple hash function for noise
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Value noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // smoothstep

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Fractal noise for more organic look
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main()
{
    vec4 texColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);

    // Generate noise pattern using screen coordinates (works with primitives)
    vec2 noiseCoord = (gl_FragCoord.xy - u_position) / 16.0; 
    float noiseValue = fbm(noiseCoord);

    // Calculate dissolve threshold
    float threshold = u_dissolve;

    // Discard pixels below threshold
    if (noiseValue < threshold) {
        discard;
    }

    // Edge glow effect
    float edge = smoothstep(threshold, threshold + u_edgeWidth, noiseValue);
    vec3 finalColor = mix(u_edgeColor, texColor.rgb, edge);

    gl_FragColor = vec4(finalColor, texColor.a);
}
