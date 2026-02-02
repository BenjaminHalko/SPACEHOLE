//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const float amount = 1.5;
const vec4 coeff = vec4(0.299,0.587,0.114, 0.);

void main()
{
    vec4 color = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
    float lum = dot(color, coeff);
    vec4 mask = (color - vec4(lum));
    mask = clamp(mask, 0.0, 1.0);
    float lumMask = dot(coeff, mask);
    lumMask = 1.0 - lumMask;
    gl_FragColor = mix(vec4(lum), color, 1.0 + amount * lumMask);
}
