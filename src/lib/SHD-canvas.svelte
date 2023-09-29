<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import * as THREE from 'three';
    import FragmentShader from '../shaders/test.glsl?raw';

    /* === THREE ============================== */
    let renderer: THREE.WebGLRenderer;
    let camera: THREE.OrthographicCamera;
    let scene: THREE.Scene;
    let plane: THREE.PlaneGeometry;
    const size = {
        width: 100,
        height: 100
    };
    let pixelRatio = 1;
    const uniforms = {
		iTime: { value: 0 },
		iResolution: { value: new THREE.Vector3() },
	};

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;

    /* === FUNCTIONS ========================== */
    /**
     * Three.js render function that is called each frame
     */
    function render(time: any): void {
        time *= 0.001; // convert to seconds

		uniforms.iTime.value = time;
        
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
            uniforms,
        });
        scene.add(new THREE.Mesh(plane, material));

        resizeRenderer()
        requestAnimationFrame(render);
	});
</script>



<svelte:window on:resize={resizeRenderer}/>

<canvas id="canvas" bind:this={canvas}></canvas>



<style lang="scss">
    #canvas {
        display: block;
    }
</style>