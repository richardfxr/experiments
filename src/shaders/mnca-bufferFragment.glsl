precision mediump float;
uniform sampler2D uTexture; 
uniform vec2 uResolution;
uniform vec2 uNeighborhoodA[108];
uniform vec2 uNeighborhoodB[36];
varying vec2 vUvs;

int GetNeighborsA(vec2 p) {
    int neighbors = 0;

    for(int i = 0; i < 108; i++) {
        // scale offset to match texture coordinates
        vec2 offset = uNeighborhoodA[i] / uResolution.xy;
        // get state of neighboring cell
        vec4 neighbor = texture2D(uTexture, p + offset); 
        neighbors += neighbor.r > 0.5 ? 1 : 0;
    }

    return neighbors;
}

int GetNeighborsB(vec2 p) {
    int neighbors = 0;

    for(int i = 0; i < 36; i++) {
        // scale offset to match texture coordinates
        vec2 offset = uNeighborhoodB[i] / uResolution.xy;
        // get state of neighboring cell
        vec4 neighbor = texture2D(uTexture, p + offset); 
        neighbors += neighbor.r > 0.5 ? 1 : 0;
    }

    return neighbors;
}

void main() {
    // previous state of cell
    float currentState = texture2D(uTexture, vUvs).r > 0.5 ? 1.0 : 0.0;
    // number of alive neighboring cells
    int neighborsA = GetNeighborsA(vUvs);
    int neighborsB = GetNeighborsB(vUvs);

    if( neighborsA >= 20 &&  neighborsA <= 22 ) { currentState = 1.0; }
    if( neighborsA >= 37 &&  neighborsA <= 63 ) { currentState = 0.0; }
    if( neighborsA >= 81 &&  neighborsA <= 92 ) { currentState = 0.0; }
    if( neighborsB >= 5 && neighborsB <= 10 ) { currentState = 0.0; }
    if( neighborsB >= 16 && neighborsB <= 24 ) { currentState = 1.0; }
    if( neighborsA >= 16 &&  neighborsA <= 19 ) { currentState = 0.0; }

    gl_FragColor = vec4(currentState, currentState, currentState, 1.0);
}