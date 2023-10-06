<script lang="ts">
    /* === IMPORTS ============================ */
    import Canvas from "$lib/SHD-canvas.svelte";
    import Slider from "$lib/SHD-slider.svelte";

    /* === VARIABLES ========================== */
    let timeScale = 2;
</script>



<main>
    <Canvas
        {timeScale} />
    <div class="controls">
        <Slider
            bind:value={timeScale}
            id="timeScale"
            min={0}
            max={6}
            step={0.1}>
            speed
        </Slider>
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
</style>