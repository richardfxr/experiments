<script context="module">
    /* === IMPORTS ============================ */
    import { writable } from 'svelte/store';

    export const timeSclaeMax = 6;
    export const timeScaleMin = 0;
    export const zoomMax = 1.3;
    export const zoomMin = 0;
    export const offsetMax = 1;
    export const offsetMin = 0;

    export const timeScale = writable(2);
    export const zoom = writable(0.5);
    export const offsetR = writable(0.498);
    export const offsetG = writable(0.268);
    export const offsetB = writable(0.068);
    export const shape = writable(1);
</script>

<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import { browser } from '$app/environment';
    import * as THREE from 'three';
    import FragmentShader from '../shaders/hypnosis.glsl?raw';

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
        zoom: { value: 1.8 - $zoom },
        offsetR: { value: $offsetR },
        offsetG: { value: $offsetG },
        offsetB: { value: $offsetB },
        shape: { value: $shape },
        mousePosition: { value: new THREE.Vector2(0.5, 0.5) }
	};
    let scaledTime = 0;
    let prevTime = 0;

    /* === CONSTANTS ========================== */
    const shapeNames = [
        "circles",
        "triangles",
        "squares",
        "pentagons"
    ];

    /* === VARIABLES ========================== */
    let dragging = false;
    let hasDragged = false;

    /* === LOCAL STORAGE ====================== */
    if (browser) {
        if (localStorage.timeScale2) timeScale.set(Number(localStorage.timeScale2));
        if (localStorage.zoom2) zoom.set(Number(localStorage.zoom2));
        if (localStorage.offsetR2) offsetR.set(Number(localStorage.offsetR2));
        if (localStorage.offsetG2) offsetG.set(Number(localStorage.offsetG2));
        if (localStorage.offsetB2) offsetB.set(Number(localStorage.offsetB2));
        if (localStorage.shape2) shape.set(Number(localStorage.shape2));
    }
    
    /* === STORES ============================= */
    timeScale.subscribe((value) => {
        if (!browser) return;
        localStorage.setItem("timeScale2", value.toString());
    });
    
    zoom.subscribe((value) => {
        if (!browser) return;
        uniforms.zoom.value = 1.8 - value;
        localStorage.setItem("zoom2", value.toString());
    });
    
    offsetR.subscribe((value) => {
        if (!browser) return;
        uniforms.offsetR.value = value;
        localStorage.setItem("offsetR2", value.toString());
    });
    
    offsetG.subscribe((value) => {
        if (!browser) return;
        uniforms.offsetG.value = value;
        localStorage.setItem("offsetG2", value.toString());
    });

    offsetB.subscribe((value) => {
        if (!browser) return;
        uniforms.offsetB.value = value;
        localStorage.setItem("offsetB2", value.toString());
    });

    shape.subscribe((value) => {
        if (!browser) return;
        uniforms.shape.value = value;
        localStorage.setItem("shape2", value.toString());
    });

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;

    /* === FUNCTIONS ========================== */
    /**
     * Three.js render function that is called each frame
     */
    function render(time: number): void {
        // update time
        let elapsedTime = time - prevTime;
        scaledTime += elapsedTime * $timeScale;
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

    function clamp(min: number, num: number, max: number): number {
        return Math.min(Math.max(num, min), max);
    }

    function handleClick(event: MouseEvent): void {
        if (event.button !== 0) return;

        if (hasDragged) {
            hasDragged = false;
            return;
        }

        shape.update((n) => {
            if (n === 4) return 1;
            else return n + 1;
        });
    }

    function handleMouseMove(event: MouseEvent): void {
        // update mousePosition
        uniforms.mousePosition.value.set(
            event.offsetX / size.width,
            event.offsetY / size.height
        );

        if (!dragging) return;

        if (event.movementX || event.movementY) hasDragged = true;

        // update G and B offsets on drag
        offsetG.update((n) => {
            return clamp(offsetMin, n + (event.movementX * 2 / size.width), offsetMax);
        });
        offsetB.update((n) => {
            return clamp(offsetMin, n + (event.movementY * 2 / size.width), offsetMax);
        });
    }

    function handleTouchmove(event: TouchEvent): void {
        if (event.touches[1]) return;
        // update mousePosition
        uniforms.mousePosition.value.set(
            event.touches[0].clientX / size.width,
            event.touches[0].clientY / size.height
        );
    }

    function handleSrollWheel(event: WheelEvent): void {
        if (Math.abs(event.deltaY) > Math.abs(event.deltaX)) {
            if (event.altKey) {
                // update timeScale for vertical scroll
                const updatedTimeScale = $timeScale - (event.deltaY / 400);
                timeScale.set(clamp(timeScaleMin, updatedTimeScale, timeSclaeMax));
                return;
            }

            // update zoom for vertical scroll
            const updatedZoom = $zoom - (event.deltaY / 2000);
            zoom.set(clamp(zoomMin, updatedZoom, zoomMax));
            return;
        }
        
        // update timeScale for horizontal scroll
        const updatedTimeScale = $timeScale - (event.deltaX / 400);
        timeScale.set(clamp(timeScaleMin, updatedTimeScale, timeSclaeMax));
    }

    /* === LIFECYCLE ========================== */
    onMount(() => {        
        // THREE
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

        resizeRenderer();
        requestAnimationFrame(render);

        return () => {
            renderer.dispose();
            console.log("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        }
	});
</script>



<svelte:window on:resize={resizeRenderer}/>

<canvas
    id="canvas"
    role="img"
    aria-label="Concentric {shapeNames[$shape - 1]} {$timeScale === 0 ? "centered on" : $timeScale <= 3 ? "emerging slowly from the center of" : "emerging quickly from the center of"} the screen, changing color as they move away from the center."
    bind:this={canvas}
    on:click={handleClick}
    on:mousedown={event => {
        if (event.button === 0) dragging = true;
    }}
    on:mouseup={event => {
        if (event.button === 0) dragging = false;
    }}
    on:mouseleave={() => dragging = false}
    on:mousemove={handleMouseMove}
    on:touchmove={handleTouchmove}
    on:wheel={handleSrollWheel}>
</canvas>
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
    :global(html, body) {
        // prevent chrome back/forward gestures
        overscroll-behavior-x: none;
    }

    #canvas {
        display: block;
        height: 100vh;
        width: 100%;
        
        background-color: black;
        touch-action: pinch-zoom;
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
        background: linear-gradient(0deg, #b700ff, #ff6200);

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