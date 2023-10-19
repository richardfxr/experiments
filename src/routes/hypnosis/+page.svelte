<script lang="ts">
    /* === IMPORTS ============================ */
    import Canvas from "$lib/SHD-canvas.svelte";
    import Slider from "$lib/SHD-slider.svelte";
    import ShapeRadios from "$lib/SHD-shapeRadios.svelte";

    /* === VARIABLES ========================== */
    let timeScale = 2;
    let zoom = 1.2;
    let phaseR = 0.498;
    let phaseG = 0.268;
    let phaseB = 0.068;
    let shape = 1;
</script>



<main>
    <Canvas
        {timeScale}
        {zoom}
        {phaseR}
        {phaseG}
        {phaseB}
        {shape} />
    <div class="controlsWrapper">
        <div class="controls">
            <Slider
                bind:value={timeScale}
                id="timeScale"
                min={0}
                max={6}
                step={0.1}
                thumbColor="#fff6a3"
                shadowColor="#e8d100">
                speed
            </Slider>
            <Slider
                bind:value={zoom}
                id="zoom"
                min={0.5}
                max={1.7}
                step={0.001}
                thumbColor="#ffd1ab"
                shadowColor="#ff7300">
                zoom
            </Slider>
            <Slider
                bind:value={phaseR}
                id="phaseR"
                min={0}
                max={1}
                step={0.001}
                thumbColor="#ffabab"
                shadowColor="#ff0000">
                red phase
            </Slider>
            <Slider
                bind:value={phaseG}
                id="phaseG"
                min={0}
                max={1}
                step={0.001}
                thumbColor="#96ff96"
                shadowColor="#00ba00">
                green phase
            </Slider>
            <Slider
                bind:value={phaseB}
                id="phaseB"
                min={0}
                max={1}
                step={0.001}
                thumbColor="#c9c9ff"
                shadowColor="#3b3bff">
                blue phase
            </Slider>
            <ShapeRadios bind:shape={shape} />
        </div>
    </div>
</main>




<style lang="scss" global>
    :root {
        // variables
        --border-width: 1px;
        --border-thick-width: 2px;
        --trans-fast: 0.15s;
        --trans-normal: 0.2s;
        --trans-slow: 0.25s;
        --slider-height: 50px;
    }

    *, *::before, *::after {
        font-family: 'General Sans', sans-serif;
    }
    
    main {
        position: relative;
    }

    #canvas {
        height: 100vh;
        width: 100%;
        background-color: black;
    }

    .controlsWrapper {
        position: absolute;
        right: 0;
        bottom: 0;
        width: min(400px, 100%);
        
        padding: 15px;
        
        .controls {
            max-height: calc(100vh - 30px);
            background-color: black;
            border-radius: 7px;
            
            overflow: auto;
        }
    }

    .label {
        color: white;
        font-size: 1rem;
        font-weight: 400;
        text-align: center;
    }
</style>