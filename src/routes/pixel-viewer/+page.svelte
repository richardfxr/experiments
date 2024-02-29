<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';

    /* === CONSTANTS ========================== */
    const width = 6;
    const height = 6;
    const image = new Uint8ClampedArray([
        0, 0, 0, 255,
        51, 0, 0, 255,
        102, 0, 0, 255,
        153, 0, 0, 255,
        204, 0, 0, 255,
        255, 0, 0, 255,
        0, 51, 0, 255,
        51, 51, 0, 255,
        102, 51, 0, 255,
        153, 51, 0, 255,
        204, 51, 0, 255,
        255, 51, 0, 255,
        0, 102, 0, 255,
        51, 102, 0, 255,
        102, 102, 0, 255,
        153, 102, 0, 255,
        204, 102, 0, 255,
        255, 102, 0, 255,
        0, 153, 0, 255,
        51, 153, 0, 255,
        102, 153, 0, 255,
        153, 153, 0, 255,
        204, 153, 0, 255,
        255, 153, 0, 255,
        0, 204, 0, 255,
        51, 204, 0, 255,
        102, 204, 0, 255,
        153, 204, 0, 255,
        204, 204, 0, 255,
        255, 204, 0, 255,
        0, 255, 0, 255,
        51, 255, 0, 255,
        102, 255, 0, 255,
        153, 255, 0, 255,
        204, 255, 0, 255,
        255, 255, 0, 255,
    ]);

    /* === VARIABLES ========================== */
    let dragging = false;
    let scale = 50;
    let translateX = 0;
    let translateY = 0;

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;
    let context: CanvasRenderingContext2D;
    let imageData: ImageData;

    function handleMouseMove(event: MouseEvent): void {
        if (!dragging) return;
        translateX += event.movementX;
        console.log(translateX);
        translateY += event.movementY;
    }

    /* === LIFECYCLE ========================== */
    onMount(() => {
        // get 2D context
        const tempContext = canvas.getContext("2d");
        if (!tempContext) {
            console.log("failed to get context");
            return;
        } else {
            context = tempContext;
        }

        // get and load imageData
        canvas.height = height;
        canvas.width = width;
        imageData = context.getImageData(0, 0, width, height);
        imageData.data.set(image);
        context.putImageData(imageData, 0, 0);
	});
</script>



<svelte:window on:mousemove={handleMouseMove} />

<div
    class="container"
    on:wheel={event => scale -= 0.1 * event.deltaY}
    on:mousedown={event => {
        if (event.button === 0) dragging = true;
    }}
    on:mouseup={event => {
        if (event.button === 0) dragging = false;
    }}
    on:mouseenter={event => {
        if (event.buttons === 1) {
            dragging = true;
        } else {
            dragging = false;
        }
    }}>
    <div
        class="scalor"
        style="transform: scale({scale}) translate({translateX / scale}px, {translateY / scale}px)">
        <canvas bind:this={canvas}></canvas>
    </div>
</div>



<style lang="scss">
    .container {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 100vh;
        overflow: hidden;
    }

    .scalor {
        width: 6px;
        height: 6px;
        transform: scale(50);
        transform-origin: center;
        image-rendering: pixelated;
    }

    canvas {
        display: block;

        touch-action: none;
    }
</style>