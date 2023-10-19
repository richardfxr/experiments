<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import * as THREE from 'three';
    import FragmentShader from '../shaders/test.glsl?raw';

    /* === PROPS ============================== */
    export let timeScale: number;
    export let zoom: number;
    export let shape: number;

    /* === THREE ============================== */
    let renderer: THREE.WebGLRenderer;
    let camera: THREE.OrthographicCamera;
    let scene: THREE.Scene;
    let plane: THREE.PlaneGeometry;
    let loaded = false;
    const size = {
        width: 100,
        height: 100
    };
    let pixelRatio = 1;
    const uniforms = {
		iTime: { value: 0 },
		iResolution: { value: new THREE.Vector3() },
        zoom: { value: zoom },
        shape: { value: shape }
	};
    let scaledTime = 0;
    let prevTime = 0;

    $: zoom, updateUniform('zoom');
    $: shape, updateUniform('shape');

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;

    /* === FUNCTIONS ========================== */
    /**
     * Three.js render function that is called each frame
     */
    function render(time: number): void {
        // update time
        let elapsedTime = time - prevTime;
        scaledTime += elapsedTime * timeScale;
        prevTime = time;

		uniforms.iTime.value = scaledTime * 0.001;// convert to seconds
        
        renderer.render(scene, camera);
        requestAnimationFrame(render);
    }

    /**
     * Resize renderer to canvas size on window resize.
     */
    function resizeRenderer(): void {
        // update canvas size
        size.width = canvas.clientWidth;
        size.height = canvas.clientHeight;
        renderer.setSize(
            size.width,
            size.height,
            false
        );

        // update pixel ratio
        pixelRatio = Math.min(window.devicePixelRatio, 2);
        renderer.setPixelRatio(pixelRatio);

        // update iResoltion
        uniforms.iResolution.value.set(
            size.width * pixelRatio,
            size.height * pixelRatio,
            1
        );
    }

    function updateUniform(uniform: 'zoom' | 'shape'): void {
        switch (uniform) {
            case 'zoom':
                uniforms.zoom.value = zoom;
                break;
            case 'shape':
                uniforms.shape.value = shape;
                break;
        }
    }

    /* === LIFECYCLE ========================== */
    onMount(() => {
		renderer = new THREE.WebGLRenderer({
            antialias: true,
            canvas
        });
        renderer.autoClearColor = false;
        
        camera = new THREE.OrthographicCamera(
            - 1, // left
            1, // right
            1, // top
            - 1, // bottom
            - 1, // near,
            1, // far
        );

        scene = new THREE.Scene();
        plane = new THREE.PlaneGeometry(2, 2);
        const material = new THREE.ShaderMaterial({
            fragmentShader: FragmentShader,
            uniforms
        });
        scene.add(new THREE.Mesh(plane, material));

        loaded = true;

        resizeRenderer()
        requestAnimationFrame(render);
	});
</script>



<svelte:window on:resize={resizeRenderer}/>

<canvas id="canvas" bind:this={canvas}></canvas>
{#if !scene && !loaded}
    <div class="text">
        <h2>Loading WebGL.</h2>
        <p>If this takes a while, reload the page.</p>
    </div>
{:else if !scene}
    <div class="text">
        <h2>WebGL is not supported.</h2>
        <p>Please try a different browser or device.</p>
    </div>
{/if}



<style lang="scss">
    #canvas {
        display: block;
    }

    .text {
        display: flex;
        flex-flow: column nowrap;
        align-items: center;
        justify-content: center;
        position: absolute;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;

        padding: 0 15px;

        h2, p {
            color: white;
            text-align: center;
        }

        h2 {
            font-size: 1.2rem;
            font-weight: 600;
        }

        p {
            font-size: 1rem;
            font-weight: 400;
        }
    }
</style>