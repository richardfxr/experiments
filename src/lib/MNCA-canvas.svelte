<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import * as THREE from 'three';
    import VertexShader from '$shaders/cellularAutomaton-vertex.glsl?raw';
    import FragmentShader from '$shaders/cellularAutomaton-fragment.glsl?raw';
    import BufferFragmentShader from '$shaders/mnca-bufferFragment.glsl?raw';
    import { neighborhoodSideLength, totalNeighborhoods } from '$lib/MNCA-controls.svelte';

    /* === PROPS ============================== */
    export let fps: number; // bind
    export let neighborhoodData: Uint8Array;

    /* === BINDINGS =========================== */
    let container: HTMLDivElement;
    let canvas: HTMLCanvasElement;

    /* === CONSTANTS ========================== */
    const neighborhoodResolution = new THREE.Vector2(
        neighborhoodSideLength * (totalNeighborhoods + 1),
        neighborhoodSideLength
    );

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
    let frames = 0;
    let prevTime = 0;
    let hasResized = false;
    // others
    let canvasWidth = 0;
    let canvasHeight = 0;
    let pixelRatio = 1;
    let resizeObserver: ResizeObserver;
    let willRandomizeCells = false;
    let randomizeMono = false;

    /* === FUNCTIONS ========================== */
    function render() {
        // render buffer scene
        renderer.setRenderTarget(renderBufferA);
        renderer.render(bufferScene, camera);

        let textureToRender = renderBufferA.texture;

        // update mesh texture
        if (hasResized && randomizeMono) {
            //@ts-ignore
            textureToRender = generateRandomMonochromeTexture();
            hasResized = false;
        } else if (hasResized) {
            //@ts-ignore
            textureToRender = generateRandomColorTexture();
            hasResized = false;
        }

        //@ts-ignore
        mesh.material.uniforms.uTexture.value = textureToRender;

        // render scene
        renderer.setRenderTarget(null);
        renderer.render(scene, camera);

        // swap buffers
        const temp = renderBufferA;
        renderBufferA = renderBufferB;
        renderBufferB = temp;

        // update uniforms
        if (willRandomizeCells) {
            if (randomizeMono) {
                bufferMaterial.uniforms.uTexture.value = generateRandomMonochromeTexture();
            } else {
                bufferMaterial.uniforms.uTexture.value = generateRandomColorTexture();
            }
            willRandomizeCells = false;
        } else {
            bufferMaterial.uniforms.uTexture.value = textureToRender;
        }
        
        // log frame rate
        frames++;
        const time = performance.now();
    
        if ( time >= prevTime + 1000 ) {
            fps = Math.round((frames * 1000) / (time - prevTime));
            frames = 0;
            prevTime = time;
        }

        window.requestAnimationFrame(render);
    }

    export function updateNeighborhoods(): void {
        // create new neighborhood data texture
        const neighborhoodDataTexture = new THREE.DataTexture(
            neighborhoodData,
            neighborhoodResolution.x,
            neighborhoodResolution.y,
            THREE.RGBAFormat
        );
        neighborhoodDataTexture.needsUpdate = true;

        // update uniform
        bufferMaterial.uniforms.uNeighborhoods.value = neighborhoodDataTexture;
    }

    export function randomizeCells(): void {
        willRandomizeCells = true;
        randomizeMono = false;
    }

    export function randomizeCellsMono(): void {
        willRandomizeCells = true;
        randomizeMono = true;
    }

    function handleResize(): void {
        // get container size & pixel ratio
        canvasWidth = container.clientWidth;
        canvasHeight = container.clientHeight;
        pixelRatio = window.devicePixelRatio;

        // update renderer
        renderer.setSize(canvasWidth, canvasHeight);
        renderer.setPixelRatio(Math.min(pixelRatio, 3));

        // update resolution uniforms
        material.uniforms.uResolution.value.set(
            canvasWidth,
            canvasHeight
        );
        bufferMaterial.uniforms.uResolution.value.set(
            canvasWidth,
            canvasHeight
        );

        // update render contexts
        renderBufferA.setSize(canvasWidth, canvasHeight);
        renderBufferB.setSize(canvasWidth, canvasHeight);

        hasResized = true;
    }

    // returns either 0 or 255
    function getRandomColor(): number {
        return 255 * Math.floor(Math.random() * 2);
    }

    function generateRandomMonochromeTexture(): THREE.DataTexture {
        // create a buffer with color data
        const size = canvasWidth * canvasHeight;
        const data = new Uint8Array(4 * size);

        for (let i = 0; i < size; i++) {
            const stride = i * 4;

            const color = getRandomColor();

            data[stride] = color;
            data[stride + 1] = color;
            data[stride + 2] = color;
            data[stride + 3] = 255;
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

    function generateRandomColorTexture(): THREE.DataTexture {
        // create a buffer with color data
        const size = canvasWidth * canvasHeight;
        const data = new Uint8Array(4 * size);

        for (let i = 0; i < size; i++) {
            const stride = i * 4;

            data[stride] = getRandomColor();
            data[stride + 1] = getRandomColor();
            data[stride + 2] = getRandomColor();
            data[stride + 3] = 255;
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
        canvasWidth = container.clientWidth;
        canvasHeight = container.clientHeight;

        // === RESIZE OBSERVER ===================
        resizeObserver = new ResizeObserver(handleResize);
        resizeObserver.observe(container, {box: 'content-box'});

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

        // neighborhood data texture
        const neighborhoodDataTexture = new THREE.DataTexture(
            neighborhoodData,
            neighborhoodResolution.x,
            neighborhoodResolution.y,
            THREE.RGBAFormat
        );
        neighborhoodDataTexture.needsUpdate = true;

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
                uTexture: { value: generateRandomColorTexture() },
                uResolution: { value: resolution },
                uNeighborhoods: { value: neighborhoodDataTexture },
                uNeighborhoodResolution: { value: neighborhoodResolution }
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

        handleResize();
        prevTime = performance.now();

        // render
        window.requestAnimationFrame(render);
    });
</script>



<div class="container" bind:this={container}>
    <canvas bind:this={canvas}></canvas>
</div>



<style lang="scss">
    .container {
        width: 100%;
        height: 100%;
    }

    canvas {
        display: block;
        width: 100%;
        height: 100%;
    }
</style>