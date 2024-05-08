<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import * as THREE from 'three';
    import VertexShader from '$shaders/halftonePainter-vertex.glsl?raw';
    import FragmentShader from '$shaders/halftonePainter-fragment.glsl?raw';
    import BufferFragmentShader from '$shaders/halftonePainter-bufferFragment.glsl?raw';

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;

    /* === CONSTANTS ========================== */
    // Conway's Game of Life rules
    // x indicates if the cell survives
    // y indicates if the cell is born
    // index indicates the number of neighbors
    const rules = [
        new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0),
        new THREE.Vector2(1, 0),
        new THREE.Vector2(0, 1),
        new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0)
    ];

    /* === VARIABLES ========================== */
    // THREE
    let scene: THREE.Scene;
    let bufferScene: THREE.Scene;
    let renderBufferA: THREE.WebGLRenderTarget;
    let renderBufferB: THREE.WebGLRenderTarget;
    let material: THREE.ShaderMaterial;
    let bufferMaterial: THREE.ShaderMaterial;
    let mesh: THREE.Mesh;
    let bufferMesh: THREE.Mesh;
    let renderer: THREE.WebGLRenderer;
    let camera: THREE.OrthographicCamera;
    // others
    let canvasWidth = 0;
    let canvasHeight = 0;
    let pixelRatio = 1;
    let resizeObserver: ResizeObserver;

    /* === FUNCTIONS ========================== */
    function render() {
        // render buffer scene
        renderer.setRenderTarget(renderBufferA);
        renderer.render(bufferScene, camera);

        // render scene
        //@ts-ignore
        mesh.material.uniforms.uTexture.value = renderBufferA.texture;
        renderer.setRenderTarget(null);
        renderer.render(scene, camera);

        // swap buffers
        const temp = renderBufferA;
        renderBufferA = renderBufferB;
        renderBufferB = temp;
        bufferMaterial.uniforms.uTexture.value = renderBufferB.texture;

        window.requestAnimationFrame(render);
    }

    function handleResize(): void {
        canvasWidth = canvas.clientWidth;
        canvasHeight = canvas.clientHeight;
        pixelRatio = window.devicePixelRatio;

        renderer.setSize(canvasWidth, canvasHeight);
        renderer.setPixelRatio(Math.min(pixelRatio, 3));

        material.uniforms.uResolution.value.x = canvasWidth;
        material.uniforms.uResolution.value.y = canvasHeight;
    }

    function generateRandomStartCondition(): THREE.DataTexture {
        // create a buffer with color data
        const size = canvasWidth * canvasHeight;
        const data = new Uint8Array(4 * size);

        for (var i = 0; i < size; i++) {
            var stride = i * 4;

            if (Math.random() < 0.5) {
                data[stride] = 255;
                data[stride + 1] = 255;
                data[stride + 2] = 255;
                data[stride + 3] = 255;
            } else {
                data[stride] = 0;
                data[stride + 1] = 0;
                data[stride + 2] = 0;
                data[stride + 3] = 255;
            }
        }

        // used the buffer to create a DataTexture
        const texture = new THREE.DataTexture(
            data,
            canvasWidth,
            canvasHeight,
            THREE.RGBAFormat
        );
        texture.needsUpdate = true;

        return texture;
    }

    /* === LIFECYCLE ========================== */
    onMount(() => {
        // initialize canvas size
        canvasWidth = canvas.clientWidth;
        canvasHeight = canvas.clientHeight;
        
        // === RESIZE OBSERVER ===================
        resizeObserver = new ResizeObserver(handleResize);
        resizeObserver.observe(canvas, {box: 'content-box'});

        // === THREE SETUP =======================
        // scenes
        scene = new THREE.Scene();
        bufferScene = new THREE.Scene();

        // buffers
        renderBufferA = new THREE.WebGLRenderTarget(
            canvasWidth,
            canvasHeight,
            {
                minFilter: THREE.NearestFilter,
                magFilter: THREE.NearestFilter,
                format: THREE.RGBAFormat,
                type: THREE.FloatType,
                stencilBuffer: false
            }
        );
        renderBufferB = new THREE.WebGLRenderTarget(
            canvasWidth,
            canvasHeight,
            {
                minFilter: THREE.NearestFilter,
                magFilter: THREE.NearestFilter,
                format: THREE.RGBAFormat,
                type: THREE.FloatType,
                stencilBuffer: false
            }
        );

        // geometry
        const geometry = new THREE.PlaneGeometry(2, 2);

        // screen resolution
        const resolution = new THREE.Vector3(
            canvasWidth,
            canvasHeight,
            pixelRatio
        );

        // materials
        material = new THREE.ShaderMaterial({
            uniforms: {
                uTexture: { value: null },
                uResolution: { value: resolution }
            },
            vertexShader: VertexShader,
            fragmentShader: FragmentShader
        });
        bufferMaterial = new THREE.ShaderMaterial({
            uniforms: {
                uTexture: { value: generateRandomStartCondition() },
                uResolution: { value: resolution },
                uRule: { value: rules }
            },
            vertexShader: VertexShader,
            fragmentShader: BufferFragmentShader
        });

        // meshes
        mesh = new THREE.Mesh(geometry, material);
        scene.add(mesh);
        bufferMesh = new THREE.Mesh(geometry, bufferMaterial);
        bufferScene.add(bufferMesh);

        // renderer
        renderer = new THREE.WebGLRenderer({
            antialias: true,
            canvas
        });
        // camera
        camera = new THREE.OrthographicCamera(
            - 1, // left
            1, // right
            1, // top
            - 1, // bottom
            0, // near,
            1, // far
        );

        // render
        window.requestAnimationFrame(render);
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