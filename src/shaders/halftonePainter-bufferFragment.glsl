precision mediump float;
uniform sampler2D uTexture; 
uniform vec2 uResolution;
uniform vec2 uRule[9];
varying vec2 vUvs;

int GetNeighbours(vec2 p) {
    int neighbors = 0;

    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            // scale offset to match texture coordinates
            vec2 offset = vec2(x, y) / uResolution.xy;	
            // get state of neighboring cell
            vec4 neighbor = texture2D(uTexture, p + offset); 
            neighbors += neighbor.r > 0.5 ? 1 : 0;
        }
    }

    return neighbors;
}

void main() {
    // previous state of cell
    float prevState = texture2D(uTexture, vUvs).r > 0.5 ? 1.0 : 0.0;
    // number of alive neighboring cells
    int neighbors = -1 * int(prevState) + GetNeighbours(vUvs);

    // use uRule to calculate current state
    vec2 result = uRule[neighbors];
    float currentState = prevState * result.x + result.y;

    gl_FragColor = vec4(currentState, currentState, currentState, 1.0);
}