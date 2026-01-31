varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float iTime;
uniform vec2 iResolution;
uniform float u_dissolve;      // 0.0 = fully visible, 1.0 = fully dissolved
uniform vec3 u_edgeColor;      // Color of the dissolve edge glow
uniform float u_edgeWidth;     // Width of the edge glow (0.0 - 0.1 works well)
uniform vec2 u_planetPos;      // Planet's screen position
uniform vec3 u_colorA;         // Primary planet color
uniform vec3 u_colorB;         // Secondary planet color

const float intensity = 0.2;

// Hash based 3D value noise
float hash(float n) {
    return fract(sin(n)*43758.5453);
}

float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;
    return mix(
        mix(
            mix(hash(n+0.0), hash(n+1.0), f.x),
            mix(hash(n+57.0), hash(n+58.0), f.x),
            f.y
        ),
        mix(
            mix(hash(n+113.0), hash(n+114.0), f.x),
            mix(hash(n+170.0), hash(n+171.0), f.x),
            f.y
        ),
        f.z
    );
}

vec3 noise3(vec3 x) {
    return vec3(
        noise(x + vec3(123.456, 0.567, 0.37)),
        noise(x + vec3(0.11, 47.43, 19.17)),
        noise(x)
    );
}

float bias(float x, float b) {
    return x/((1.0/b-2.0)*(1.0-x)+1.0);
}

float gain(float x, float g) {
    float t = (1.0/g-2.0)*(1.0-(2.0*x));    
    return x<0.5 ? (x/(t+1.0)) : (t-x)/(t-1.0);
}

mat3 rotation(float angle, vec3 axis) {
    float s = sin(-angle);
    float c = cos(-angle);
    float oc = 1.0 - c;
    vec3 sa = axis * s;
    vec3 oca = axis * oc;
    return mat3(
        oca.x * axis + vec3(c, -sa.z, sa.y),
        oca.y * axis + vec3(sa.z, c, -sa.x),        
        oca.z * axis + vec3(-sa.y, sa.x, c)
    );    
}

vec3 fbm(vec3 x, float H, float L, int oc) {
    vec3 v = vec3(0.0);
    float f = 1.0;
    for(int i = 0; i < 10; i++) {
        if(i >= oc) break;
        float w = pow(f, -H);
        v += noise3(x)*w;
        x *= L;
        f *= L;
    }
    return v;
}

vec3 smf(vec3 x, float H, float L, int oc, float off) {
    vec3 v = vec3(1.0);
    float f = 1.0;
    for(int i = 0; i < 10; i++) {
        if(i >= oc) break;
        v *= off + f*(noise3(x)*2.0-1.0);
        f *= H;
        x *= L;
    }
    return v;    
}

vec4 map(vec3 p) {
    p -= vec3(1.0, 0.1, 0.0) * iTime * 0.01;
    p *= 4.0;
    
    vec3 axis = 4.0 * fbm(p, 0.5, 2.0, 8);
    vec3 colorVec = 0.5 * 5.0 * fbm(p*0.3, 0.5, 2.0, 7);
    p += colorVec;
    
    float mag = 0.75e5;
    vec3 colorMod = mag * smf(p, 0.7, 2.0, 8, 0.2);
    colorVec += colorMod;
    
    colorVec = rotation(3.0*length(axis), normalize(axis))*colorVec;
    colorVec *= 0.1;
    
    vec4 res;
    res.xyz = colorVec;
    res.w = length(colorVec)*8.0;
    res = clamp(res, vec4(0.0), vec4(1.0));
    
    return res;
}

vec4 raymarch(vec3 ro, vec3 rd) {
    vec4 sum = vec4(0.0);
    float t = 0.1;
    
    for(int i = 0; i < 64; i++) {
        if(sum.a > 0.99) continue;
        
        vec3 pos = ro + t*rd;
        vec4 col = map(pos);
        
        col.a *= 0.35 * (t*8.0);
        col.rgb *= col.a;
        
        sum = sum + col*(1.0 - sum.a);    
        t += max(0.1, 0.025*t);
    }
    
    sum.xyz /= (0.001+sum.w);
    return clamp(sum, 0.0, 1.0);
}

// 2D hash function for dissolve noise
float hashD(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// 2D value noise for dissolve
float noiseD(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // smoothstep

    float a = hashD(i);
    float b = hashD(i + vec2(1.0, 0.0));
    float c = hashD(i + vec2(0.0, 1.0));
    float d = hashD(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Fractal noise for more organic look (2D version)
float fbmD(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noiseD(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

vec4 dissolve(vec4 texColor)
{
    // Skip dissolve if not active
    if (u_dissolve <= 0.0) {
        return texColor;
    }

    // Generate noise pattern relative to planet position
    vec2 noiseCoord = (gl_FragCoord.xy - u_planetPos) / 16.0;
    float noiseValue = fbmD(noiseCoord);

    // Calculate dissolve threshold
    float threshold = u_dissolve;

    // Discard pixels below threshold
    if (noiseValue < threshold) {
        discard;
    }

    // Edge glow effect
    float edge = smoothstep(threshold, threshold + u_edgeWidth, noiseValue);
    vec3 finalColor = mix(u_edgeColor, texColor.rgb, edge);

    return vec4(finalColor, texColor.a);
}

void main() {
    vec2 q = v_vTexcoord;
    vec2 p = -1.0 + 2.0*q;
    p.x *= iResolution.x/iResolution.y;
    
    float mo_x = sin(iTime*0.0125);
    
    // Camera setup
    vec3 ro = 4.0*normalize(vec3(cos(2.75-3.0*mo_x), 0.7+1.0, sin(2.75-3.0*mo_x)));
    vec3 ta = vec3(0.0, 1.0, 0.0);
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(vec3(0.0,1.0,0.0), ww));
    vec3 vv = normalize(cross(ww,uu));
    vec3 rd = normalize(p.x*uu + p.y*vv + 1.5*ww);
    
    vec4 res = raymarch(ro, rd);
    vec3 col = res.xyz;

	float intense = dot(col, vec3(0.5));
	col = mix(col * (1.0 + intensity), vec3(intense), intensity * -0.5);

    // Remap colors to palette with expanded range
    float lum = dot(col, vec3(0.299, 0.587, 0.114));
    float t = clamp((lum - 0.3) * 2.5, 0.0, 1.0);  // expand contrast
    vec3 palette = mix(u_colorA, u_colorB, t);
    col = palette * (0.6 + lum * 0.8);  // vary brightness

    gl_FragColor = v_vColour * vec4(col, 1.0);
    
    gl_FragColor = dissolve(gl_FragColor);
}
