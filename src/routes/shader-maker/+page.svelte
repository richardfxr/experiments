<script lang="ts">
    /* === IMPORTS ============================ */
    import Canvas from "$lib/SHD-canvas.svelte";
    import Slider from "$lib/SHD-slider.svelte";
    import ShapeRadios from "$lib/SHD-shapeRadios.svelte";

    /* === VARIABLES ========================== */
    let timeScale = 2;
    let zoom = 1.2;
    let shape = 1;
</script>



<main>
    <Canvas
        {timeScale}
        {zoom}
        {shape} />
    <div class="controls">
        <Slider
            bind:value={timeScale}
            id="timeScale"
            min={0}
            max={6}
            step={0.1}>
            speed
        </Slider>
        <Slider
            bind:value={zoom}
            id="zoom"
            min={0.5}
            max={1.7}
            step={0.001}>
            zoom
        </Slider>
        <ShapeRadios bind:shape={shape} />
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
        background-color: rebeccapurple;
    }

    .controls {
        position: absolute;
        right: 0;
        bottom: 0;
        width: min(400px, 100%);
        background-color: black;
    }

    .label {
        color: white;
        font-size: 1rem;
        font-weight: 400;
        text-align: center;
    }
</style>