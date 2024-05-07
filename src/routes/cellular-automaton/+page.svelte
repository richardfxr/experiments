<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import VertexShaderSource from '$shaders/halftonePainter-vertex.glsl?raw';
    import FragmentShaderSource from '$shaders/halftonePainter-fragment.glsl?raw';

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;

    /* === VARIABLES ========================== */
    // WebGL
    let gl: WebGLRenderingContext;
    let fragmentShader: WebGLShader;
    let vertexShader: WebGLShader;
    let program: WebGLProgram;
    let positionAttributeLocation: number;
    let positionBuffer: WebGLBuffer;
    let resolutionUniformLocation: WebGLUniformLocation;
    let translationUniformLocation: WebGLUniformLocation;
    let rotationUniformLocation: WebGLUniformLocation;
    let colorUniformLocation: WebGLUniformLocation;
    // Other
    let displayWidth = 0;
    let displayHeight = 0;
    let resizeObserver: ResizeObserver;

    /* === FUNCTIONS ========================== */
    function createShader(type: number, source: string): WebGLShader {
        const shader = gl.createShader(type);
        if (!shader) throw new Error('Failed to create shader.');

        gl.shaderSource(shader, source);
        gl.compileShader(shader);

        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            const shaderInfoLog = gl.getShaderInfoLog(shader);
            gl.deleteShader(shader);
            throw new Error('Failed to compile shader: ' + shaderInfoLog);
        } 

        return shader;
    }

    function draw():void {
        // clear canvas
        gl.clearColor(0, 0, 0, 0);
        gl.clear(gl.COLOR_BUFFER_BIT);

        // use program
        gl.useProgram(program);

        gl.enableVertexAttribArray(positionAttributeLocation);

        // Bind the position buffer.
        gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

        // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
        let size = 2;          // 2 components per iteration
        let type = gl.FLOAT;   // the data is 32bit floats
        let normalize = false; // don't normalize the data
        let stride = 0;        // 0 = move forward size * sizeof(type) each iteration to get the next position
        let offset = 0;        // start at the beginning of the buffer
        gl.vertexAttribPointer(positionAttributeLocation, size, type, normalize, stride, offset);

        // set uniforms
        gl.uniform2f(resolutionUniformLocation, gl.canvas.width, gl.canvas.height);
        gl.uniform2f(translationUniformLocation, 100, 150);
        gl.uniform2f(rotationUniformLocation, 0, 1);
        gl.uniform4f(colorUniformLocation, 1, 0, 1, 1);

        let primitiveType = gl.TRIANGLES;
        let drawOffset = 0;
        let count = 6;
        gl.drawArrays(primitiveType, drawOffset, count);
    }

    function handleResize(entries: ResizeObserverEntry[]): void {
        for (const entry of entries) {
            let width: number;
            let height: number;
            let pixelRatio = window.devicePixelRatio;
            if (entry.devicePixelContentBoxSize) {
                width = entry.devicePixelContentBoxSize[0].inlineSize;
                height = entry.devicePixelContentBoxSize[0].blockSize;
                // pixel ratio already in width and height
                pixelRatio = 1;
            } else if (entry.contentBoxSize) {
                width = entry.contentBoxSize[0].inlineSize;
                height = entry.contentBoxSize[0].blockSize;
            } else {
                width = entry.contentRect.width;
                height = entry.contentRect.height;
            }

            // update display size
            displayWidth = Math.round(width * pixelRatio);
            displayHeight = Math.round(height * pixelRatio);
        }

        resizeCanvas();
        draw();
    }

    function resizeCanvas(): void {
        if (
            canvas.width === displayWidth &&
            canvas.height === displayHeight
        ) return;

        canvas.width = displayWidth;
        canvas.height = displayHeight;
        gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
    }

    /* === LIFECYCLE ========================== */
    onMount(() => {
        // initialize WebGL
        try {
            // get WebGL rendering context
            const tempGl = canvas.getContext('webgl');
            if (!tempGl) throw new Error('Failed to get WebGL rendering context.');
            gl = tempGl;

            // create shaders
            vertexShader = createShader(gl.VERTEX_SHADER, VertexShaderSource);
            fragmentShader = createShader(gl.FRAGMENT_SHADER, FragmentShaderSource);

            // create WebGL program
            const tempProgram = gl.createProgram();
            if (!tempProgram) throw new Error('Failed to create WebGL program.');
            gl.attachShader(tempProgram, vertexShader);
            gl.attachShader(tempProgram, fragmentShader);
            gl.linkProgram(tempProgram);
            if (!gl.getProgramParameter(tempProgram, gl.LINK_STATUS)) {
                const programInfoLog = gl.getProgramInfoLog(tempProgram);
                gl.deleteProgram(tempProgram);
                throw new Error('Failed to link program: ' + programInfoLog);
            }
            program = tempProgram;

            // look up attribute location
            positionAttributeLocation = gl.getAttribLocation(program, 'a_position');

            // look up uniform locations
            // u_resolution
            const tempResolutionUniformLocation = gl.getUniformLocation(program, 'u_resolution');
            if (!tempResolutionUniformLocation) throw new Error('Failed to get resolution uniform location.');
            resolutionUniformLocation = tempResolutionUniformLocation;
            // u_translation
            const tempTranslationUniformLocation = gl.getUniformLocation(program, 'u_translation');
            if (!tempTranslationUniformLocation) throw new Error('Failed to get translation uniform location.');
            translationUniformLocation = tempTranslationUniformLocation;
            // u_rotation
            const tempRotationUniformLocation = gl.getUniformLocation(program, 'u_rotation');
            if (!tempRotationUniformLocation) throw new Error('Failed to get rotation uniform location.');
            rotationUniformLocation = tempRotationUniformLocation;
            // u_color
            const tempColorUniformLocation = gl.getUniformLocation(program, 'u_color');
            if (!tempColorUniformLocation) throw new Error('Failed to get color uniform location.');
            colorUniformLocation = tempColorUniformLocation;

            // create & bind buffer
            const tempPositionBuffer = gl.createBuffer();
            if (!tempPositionBuffer) throw new Error('Failed to create buffer.');
            positionBuffer = tempPositionBuffer;
            gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

            // add data to buffer
            const positions = [
                10, 20,
                80, 20,
                10, 30,
                10, 30,
                80, 20,
                80, 30,
            ];
            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);
        } catch (error: unknown) {
            console.error(error);
        }

        // instantiate ResizeObserver
        resizeObserver = new ResizeObserver(handleResize);
        resizeObserver.observe(canvas, {box: 'content-box'});
        try {
            resizeObserver.observe(canvas, {box: 'device-pixel-content-box'});
        } catch (error: unknown) {
            // fallback if device-pixel-content-box is not supported
            resizeObserver.observe(canvas, {box: 'content-box'});
        }

        draw();
    });
</script>



<main>
    <canvas bind:this={canvas}></canvas>
</main>



<style lang="scss">
    main {
        height: 100vh;
    }

    canvas {
        display: block;
        width: 100%;
        height: 100%;
    }
</style>