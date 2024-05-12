<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import * as THREE from 'three';
    import VertexShader from '$shaders/cellularAutomaton-vertex.glsl?raw';
    import FragmentShader from '$shaders/cellularAutomaton-fragment.glsl?raw';
    import BufferFragmentShader from '$shaders/mnca-bufferFragment.glsl?raw';
  import { neighborhoodSideLength, totalNeighborhoods } from './MNCA-controls.svelte';

    /* === PROPS ============================== */
    export let fps: number; // bind
    export let neighborhoodData: Uint8Array;

    /* === BINDINGS =========================== */
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

        // update uniforms
        bufferMaterial.uniforms.uTexture.value = renderBufferB.texture;

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

    function handleResize(): void {
        canvasWidth = canvas.clientWidth;
        canvasHeight = canvas.clientHeight;
        pixelRatio = window.devicePixelRatio;

        renderer.setSize(canvasWidth, canvasHeight);
        renderer.setPixelRatio(Math.min(pixelRatio, 3));

        material.uniforms.uResolution.value.x = canvasWidth;
        material.uniforms.uResolution.value.y = canvasHeight;
    }

    // returns either 0 or 255
    function getRandomColor(): number {
        return 255 * Math.floor(Math.random() * 2);
    }

    // mono crhome version of generateRandomStartCondition()
    // function generateRandomStartCondition(): THREE.DataTexture {
    //     // create a buffer with color data
    //     const size = canvasWidth * canvasHeight;
    //     const data = new Uint8Array(4 * size);

    //     for (let i = 0; i < size; i++) {
    //         const stride = i * 4;

    //         const color = getRandomColor();

    //         data[stride] = color;
    //         data[stride + 1] = color;
    //         data[stride + 2] = color;
    //         data[stride + 3] = 255;
    //     }

    //     // used the buffer to create a DataTexture
    //     const texture = new THREE.DataTexture(
    //         data,
    //         canvasWidth,
    //         canvasHeight,
    //         THREE.RGBAFormat
    //     );
    //     texture.needsUpdate = true;

    //     return texture;
    // }

    function generateRandomStartCondition(): THREE.DataTexture {
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
                uTexture: { value: generateRandomStartCondition() },
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

        prevTime = performance.now();

        // render
        window.requestAnimationFrame(render);
    });
</script>



<canvas bind:this={canvas}></canvas>



<style lang="scss">
    canvas {
        display: block;
        width: 100%;
        height: 100%;
    }
</style>