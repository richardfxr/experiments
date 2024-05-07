// attributes
attribute vec2 a_position;

// uniforms
uniform vec2 u_resolution;
uniform vec2 u_translation;
uniform vec2 u_rotation;

void main() {
    // rotate
    vec2 rotatedPosition = vec2(
        a_position.x * u_rotation.y + a_position.y * u_rotation.x,
        a_position.y * u_rotation.y - a_position.x * u_rotation.x
    );

    // translate
    vec2 translatedPosition = rotatedPosition + u_translation;
    
    // convert the position from pixels to clip space
    vec2 clipSpace = translatedPosition / u_resolution * 2.0 - 1.0;
 
    // flip clip space y direction
    gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
}