#include <common>

uniform vec3 iResolution;
uniform float iTime;

vec3 palette( in float t ) {
    vec3 a = vec3(0.500, 0.500, 0.500);
    vec3 b = vec3(0.500, 0.500, 0.500);
    vec3 c = vec3(1.000, 1.000, 1.000);
    vec3 d = vec3(0.498, 0.268, 1.068);

    return a + b*cos( 6.28318*(c*t+d) );
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

    float dis = length(uv);
    vec3 color = palette(dis);

    dis = sin(dis * 35. - 5.5 * iTime) / 10.;
    dis = abs(dis);

    dis = 0.05 / dis;

    color *= dis;

    fragColor = vec4(color, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}