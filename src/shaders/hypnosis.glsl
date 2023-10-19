#include <common>

uniform vec3 iResolution;
uniform float iTime;
uniform float zoom;
uniform float phaseR;
uniform float phaseG;
uniform float phaseB;
uniform float shape;

vec3 palette( in float t ) {
    vec3 a = vec3(0.500, 0.500, 0.500);
    vec3 b = vec3(0.500, 0.500, 0.500);
    vec3 c = vec3(1.000, 1.000, 1.000);
    vec3 d = vec3(phaseR, phaseG, phaseB);

    return a + b*cos( 6.28318*(c*t+d) );
}

float sdTriangle( in vec2 p, in float r ) {
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

float sdSquare( in vec2 p, in float size ) {
    vec2 d = abs(p) - vec2(size, size);
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdPentagon( in vec2 p, in float r ) {
    const vec3 k = vec3(0.809016994,0.587785252,0.726542528);
    p.x = abs(p.x);
    p -= 2.0*min(dot(vec2(-k.x,k.y),p),0.0)*vec2(-k.x,k.y);
    p -= 2.0*min(dot(vec2( k.x,k.y),p),0.0)*vec2( k.x,k.y);
    p -= vec2(clamp(p.x,-r*k.z,r*k.z),r);    
    return length(p)*sign(p.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // ranges from -1 to 1 for both x and y. Centered at (0, 0)
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;
    // adapt to aspect ratio
    if (iResolution.x > iResolution.y) {
        uv.x *= iResolution.x / iResolution.y;
    } else {
        uv.y *= iResolution.y / iResolution.x;
    }

    float dis;
    if (shape == 1.) {
        dis = (length(uv) - 0.08) * zoom;
    } else if (shape == 2.)  {
        dis = sdTriangle(uv, 0.22) * zoom;
    } else if (shape == 3.) {
        dis = sdSquare(uv, 0.13) * zoom;
    } else if (shape == 4.) {
        dis = sdPentagon(uv, 0.16) * zoom;
    }
    vec3 color = palette(dis / 3. + (sin(iTime / 6.)));

    dis = sin(dis * dis * 8. - iTime) / 10.;
    dis = abs(dis);

    dis = 0.04 / dis;

    color *= dis;

    fragColor = vec4(color, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}