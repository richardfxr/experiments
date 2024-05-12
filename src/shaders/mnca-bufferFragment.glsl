precision mediump float;
uniform sampler2D uTexture; 
uniform vec2 uResolution;
uniform sampler2D uNeighborhoods;
uniform vec2 uNeighborhoodResolution;
varying vec2 vUvs;

float GetNewState(float neighborsA, float neighborsB, float neighborsC, float neighborsD) {
    float newState = -1.0;

    if(neighborsA >= 20.0 && neighborsA <= 22.0) {newState = 1.0;}
    if(neighborsA >= 37.0 &&  neighborsA <= 63.0) {newState = 0.0;}
    if(neighborsA >= 81.0 &&  neighborsA <= 92.0) {newState = 0.0;}
    if(neighborsB >= 5.0 && neighborsB <= 10.0) {newState = 0.0;}
    if(neighborsB >= 16.0 && neighborsB <= 24.0) {newState = 1.0;}
    if(neighborsC >= 3.0 && neighborsC <= 7.0) {newState = 0.0;}
    // if(neighborsC >= 11.0 && neighborsC <= 12.0) {newState = 1.0;}
    if(neighborsD == 5.0) {newState = 1.0;}
    // if(neighborsD >= 24.0 && neighborsD <= 25.0) {newState = 1.0;}
    // if(neighborsD >= 40.0 && neighborsD <= 42.0) {newState = 0.0;}
    // if(neighborsD >= 45.0 && neighborsD <= 68.0) {newState = 1.0;}
    if(neighborsA >= 16.0 &&  neighborsA <= 19.0) {newState = 0.0;}

    return newState;
}

void main() {
    // previous state of cell
    vec3 currentState = texture2D(uTexture, vUvs).rgb;
    // number of alive neighboring cells
    vec3 neighborsA = vec3(0.0);
    vec3 neighborsB = vec3(0.0);
    vec3 neighborsC = vec3(0.0);
    vec3 neighborsD = vec3(0.0);

    // get one pixel in each texture coordinate
    vec2 pixel = vec2(1.0, 1.0) / uResolution.xy;
    vec2 neighborhoodPixel = vec2(1.0, 1.0) / vec2(76.0, 16.0);

    // loop through 15 x 15 area around cell
    // starts at 1 because texture2D is 1-indexed
    for(int y = 1; y < 16; y++) {
        for (int x = 1; x < 16; x++) {
            // neighborhood shape data:
            // R: neighborhoodA
            // G: neighborhoodB
            // B: neighborhoodC
            // A: neighborhoodD
            // values:
            // 1.0: cell in included in neighborhood
            // 0.0: cell is not included in neighborhood
            vec4 included = texture2D(
                uNeighborhoods,
                vec2(x, y) * neighborhoodPixel
            );
            // scale offset to match texture coordinates
            vec2 offset = vec2(x - 8, y - 8) * pixel;
            // get state of cell
            vec3 cell = texture2D(uTexture, vUvs + offset).rgb; 
            // update neighbors
            neighborsA += included.r * cell;
            neighborsB += included.g * cell;
            neighborsC += included.b * cell;
            neighborsD += included.a * cell;
        }
    }

    float newStateR = GetNewState(neighborsA.r, neighborsB.r, neighborsC.g, neighborsD.b);
    float newStateG = GetNewState(neighborsA.g, neighborsB.g, neighborsC.b, neighborsD.r);
    float newStateB = GetNewState(neighborsA.b, neighborsB.b, neighborsC.r, neighborsD.g);

    gl_FragColor = vec4(
        newStateR == -1.0 ? currentState.r : newStateR,
        newStateG == -1.0 ? currentState.g : newStateG,
        newStateB == -1.0 ? currentState.b : newStateB,
        1.0
    );
}