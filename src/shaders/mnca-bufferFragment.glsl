precision mediump float;
uniform sampler2D uTexture; 
uniform vec2 uResolution;
uniform sampler2D uNeighborhoods;
uniform vec2 uNeighborhoodResolution;
varying vec2 vUvs;

vec2 GetPosition(float neighbors, float offset) {
    return vec2(
        mod(neighbors, 15.0) + 1.0 + 15.0 * offset,
        floor(neighbors / 15.0) + 1.0
    );
}

float GetNewState(
    float currentState,
    float neighborsA,
    float neighborsB,
    float neighborsC,
    float neighborsD,
    vec2 neighborhoodPixel
) {
    float newState = currentState;
    vec2 positionA = GetPosition(neighborsA, 1.0);
    vec2 positionB = GetPosition(neighborsB, 2.0);
    vec2 positionC = GetPosition(neighborsC, 3.0);
    vec2 positionD = GetPosition(neighborsD, 4.0);

    vec4 rulesA= texture2D(
        uNeighborhoods,
        positionA * neighborhoodPixel
    );
    vec4 rulesB= texture2D(
        uNeighborhoods,
        positionB * neighborhoodPixel
    );
    vec4 rulesC= texture2D(
        uNeighborhoods,
        positionC * neighborhoodPixel
    );
    vec4 rulesD= texture2D(
        uNeighborhoods,
        positionD * neighborhoodPixel
    );

    newState = rulesA.r * newState + rulesA.g;
    newState = rulesB.r * newState + rulesB.g;
    newState = rulesC.r * newState + rulesC.g;
    newState = rulesD.r * newState + rulesD.g;
    newState = rulesA.b * newState + rulesA.a;
    newState = rulesB.b * newState + rulesB.a;
    newState = rulesC.b * newState + rulesC.a;
    newState = rulesD.b * newState + rulesD.a;

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

    float newStateR = GetNewState(currentState.r, neighborsA.r, neighborsB.r, neighborsC.g, neighborsD.b, neighborhoodPixel);
    float newStateG = GetNewState(currentState.g, neighborsA.g, neighborsB.g, neighborsC.b, neighborsD.r, neighborhoodPixel);
    float newStateB = GetNewState(currentState.b, neighborsA.b, neighborsB.b, neighborsC.r, neighborsD.g, neighborhoodPixel);

    gl_FragColor = vec4(
        newStateR,
        newStateG,
        newStateB,
        1.0
    );
}