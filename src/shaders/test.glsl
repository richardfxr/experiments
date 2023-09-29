#include <common>

uniform vec3 iResolution;
uniform float iTime;

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
    dis = sin(dis * 8. - 2. * iTime) / 8.;
    dis = abs(dis);

    dis = smoothstep(0.0, 0.1, dis);

    fragColor = vec4(0.0, dis, dis, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}