precision mediump float;
uniform sampler2D uTexture; 
varying vec2 vUvs;

void main() {
    // sample from uTexture
    vec4 initTexture = texture2D(uTexture, vUvs);
    // return corresponging pixel color
    vec3 color = initTexture.rgb;
    gl_FragColor = vec4(color, 1.0);
}