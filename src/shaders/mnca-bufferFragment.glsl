precision mediump float;
uniform sampler2D uTexture; 
uniform vec2 uResolution;
uniform vec2 uNeighborhoodA[108];
uniform vec2 uNeighborhoodB[36];
varying vec2 vUvs;

vec3 GetNeighborsA(vec2 p) {
    vec3 neighbors = vec3(0.0);

    for(int i = 0; i < 108; i++) {
        // scale offset to match texture coordinates
        vec2 offset = uNeighborhoodA[i] / uResolution.xy;
        // get state of neighboring cell
        vec4 neighbor = texture2D(uTexture, p + offset); 
        neighbors += vec3(
            neighbor.r > 0.5 ? 1.0 : 0.0,
            neighbor.g > 0.5 ? 1.0 : 0.0,
            neighbor.b > 0.5 ? 1.0 : 0.0
        );
    }

    return neighbors;
}

float GetNewState(float neighborsA, float neighborsB) {
    float newState = -1.0;

    if(neighborsA >= 20.0 && neighborsA <= 22.0) {newState = 1.0;}
    if(neighborsA >= 37.0 &&  neighborsA <= 63.0) {newState = 0.0;}
    if(neighborsA >= 81.0 &&  neighborsA <= 92.0) {newState = 0.0;}
    if(neighborsB >= 5.0 && neighborsB <= 10.0) {newState = 0.0;}
    if(neighborsB >= 16.0 && neighborsB <= 24.0) {newState = 1.0;}
    if(neighborsA >= 16.0 &&  neighborsA <= 19.0) {newState = 0.0;}

    return newState;
}

vec3 GetNeighborsB(vec2 p) {
    vec3 neighbors = vec3(0.0);

    for(int i = 0; i < 36; i++) {
        // scale offset to match texture coordinates
        vec2 offset = uNeighborhoodB[i] / uResolution.xy;
        // get state of neighboring cell
        vec4 neighbor = texture2D(uTexture, p + offset); 
        neighbors += neighbor.rgb;
    }

    return neighbors;
}

void main() {
    // previous state of cell
    vec3 currentState = texture2D(uTexture, vUvs).rgb;
    // number of alive neighboring cells
    vec3 neighborsA = GetNeighborsA(vUvs);
    vec3 neighborsB = GetNeighborsB(vUvs);

    float newStateR = GetNewState(neighborsA.r, neighborsB.r);
    float newStateG = GetNewState(neighborsA.g, neighborsB.g);
    float newStateB = GetNewState(neighborsA.b, neighborsB.b);

    gl_FragColor = vec4(
        newStateR == -1.0 ? currentState.r : newStateR,
        newStateG == -1.0 ? currentState.g : newStateG,
        newStateB == -1.0 ? currentState.b : newStateB,
        1.0
    );
}