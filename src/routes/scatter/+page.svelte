<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import Controls from "$lib/SCT-controls.svelte";
    import Lines from '$lib/SCT-lines.svelte';

    /* === VARIABLES ========================== */
    let numPoints = 8;
    let canvas: HTMLDivElement;
    let origin = { x: 50, y: 50 };
    let points = [
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
        { x: 50, y: 50 },
    ];
    let scatterInterval: number | null = null;
    let scatterIndex = 0;
    let scattered = false;
    let awaitingAnimation = false;
    let animationCompleted = false;

    /* === FUNCTIONS ========================== */
    function scatterPoint(): void {
        let randomArr = new Uint32Array(2);
        crypto.getRandomValues(randomArr);

        points[scatterIndex] = {
            x: randomArr[0] / (0xffffffff + 1) * 100,
            y: randomArr[1] / (0xffffffff + 1) * 100
        };

        // force Svelte to update
        points = points;

        scatterIndex++;
        if (scatterIndex >= numPoints && !scattered) {
            awaitingAnimation = true;
            scattered = true;
            setTimeout(() => {
                if (awaitingAnimation) {
                    animationCompleted = true;
                    awaitingAnimation = false;
                }
            }, 200);
        }
        if (scatterIndex >= points.length) cancelScatter();
    }

    function cancelScatter(): void {
        if (!scatterInterval) return;

        // reset scatterInterval and scatterIndex
        clearInterval(scatterInterval);
        scatterInterval = null;
        scatterIndex = 0;
    }

    function scatterPointsAt(x?: number, y?:number): void {
        if (x && y) origin = { x, y };

        cancelScatter();
        awaitingAnimation = false;
        scattered = false;
        animationCompleted = false;

        points.forEach(point => {
            point.x = origin.x;
            point.y = origin.y;
        });

        // force Svelte to update
        points = points;

        // initialize scatterInterval
        scatterInterval = setInterval(scatterPoint, 25);
    }

    function handleClick(e: MouseEvent): void {
        if (!canvas || !e) return;
        let percentageX = e.clientX / canvas.offsetWidth * 100;
        let percentageY = e.clientY / canvas.offsetHeight * 100;
        scatterPointsAt(percentageX, percentageY);
    }

    /* === LIFECYCLES ========================= */
    onMount(() => {
		scatterPointsAt();
	});
</script>



<svelte:head>
    <title>Scatter</title>
    <meta
        name="description"
        content="A simple page that scatters a specified number of points on the screen."
    />
    <link rel="icon" href="SCT-favicon.png" />
    <meta name="theme-color" content="#f7f5ee" />
    <!-- open graph image -->
    <meta property="og:image" content="/SCT-og-image-1.jpg" />
    <meta property="og:image:type" content="image/jpeg" />
    <meta property="og:image:width" content="1200" />
    <meta property="og:image:height" content="630" />
    <meta property="og:image:alt" content="Eight dots scattered across the page." />
</svelte:head>

<main>
    <Controls
        bind:numPoints={numPoints}
        minPoints={1}
        maxPoints={points.length}
        {scatterIndex}
        {scattered}
        on:scatter={() => scatterPointsAt()} />
    
    <div
        class="canvas"
        on:click={handleClick}
        on:keypress={e => {
            if (e.code === 'Enter') scatterPointsAt();
        }}
        bind:this={canvas}>
        <div
            class="origin"
            style={`transform: translate(${origin.x}%, ${origin.y}%);`}>
            <div></div>
        </div>
        <ul class="points">
            {#each {length: points.length} as _, i (i)}
                <li
                    class="point"
                    class:shown={i < numPoints}
                    style={`transform: translate(${points[i].x}%, ${points[i].y}%);`}>
                    <div></div>
                </li>
            {/each}
        </ul>
        <Lines
            {numPoints}
            {origin}
            {points}
            {animationCompleted} />
    </div>
</main>



<style lang="scss">
    // === INTERNAL VARIABLES =====================
    $_origin-size: 10px;
    $_origin-border-offset: -10px;
    $_point-size: 11px;
    $_point-border-offset: -8px;

    :root {
        // variables
        --SCT-border-width: 1px;
        --SCT-border-thick-width: 2px;
        --SCT-trans-fast: 0.15s;
        --SCT-trans-normal: 0.2s;
        --SCT-trans-slow: 0.25s;
        --SCT-trans-cubic-1: cubic-bezier(0, .36, .34, 1);
        --SCT-controls-height: 50px;
        --SCT-controls-bottom: 10px;

        // colors
        --SCT-clr-bg: #f7f5ee;
        --SCT-clr-red: #c1272d;
        --SCT-clr-line: #cfcfbf;
        --SCT-clr-point-outline: #86857b;
        --SCT-clr-controls-text: #ffffff;
        --SCT-clr-controls-bg: #666666;
        --SCT-clr-controls-bg-hover: #585858;
        --SCT-clr-controls-bg-active: #474747;
    }

    *, *::before, *::after {
        font-family: 'General Sans', sans-serif;
    }

    main {
        height: 100vh;
        background-color: var(--SCT-clr-bg);
        overflow: hidden;
    }

    .canvas {
        position: relative;
        height: calc(100vh - var(--SCT-controls-height) - var(--SCT-controls-bottom));
        cursor: crosshair;

        .origin, .point {
            display: flex;
            align-items: start;
            justify-content: start;
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;

            div {
                position: relative;

                &::before {
                    content: "";
                    position: absolute;

                    border: solid var(--SCT-border-width) var(--SCT-clr-controls-bg);
                }
            }
        }

        .origin {
            transition: transform var(--SCT-trans-normal) var(--SCT-trans-cubic-1);

            div {
                width: $_origin-size;
                height: $_origin-size;

                background-color: var(--SCT-clr-bg);
                border: solid var(--SCT-border-thick-width) var(--SCT-clr-red);
                border-radius: 1000px;
                margin: calc(-0.5 * $_origin-size) 0 0 calc(-0.5 * $_origin-size);

                &::before {
                    top: $_origin-border-offset;
                    right: $_origin-border-offset;
                    bottom: $_origin-border-offset;
                    left: $_origin-border-offset;
                    border-radius: 1000px;
                }
            }
        }

        .point {
            opacity: 0;

            transition: transform var(--SCT-trans-normal) var(--SCT-trans-cubic-1),
                        opacity var(--SCT-trans-fast) ease-in-out;

            &.shown {
                opacity: 1;
            }

            div {
                width: $_point-size;
                height: $_point-size;

                background-color: var(--SCT-clr-controls-bg);
                margin: calc(-0.5 * $_point-size) 0 0 calc(-0.5 * $_point-size);

                &::before {
                    top: $_point-border-offset;
                    right: $_point-border-offset;
                    bottom: $_point-border-offset;
                    left: $_point-border-offset;

                    border-color: var(--SCT-clr-point-outline);
                }
            }
        }
    }
</style>