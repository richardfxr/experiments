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
    let scatterInterval: NodeJS.Timer | null = null;
    let scatterIndex = 0;
    let scattered = false;
    let awaitingAnimation = false;
    let animationCompleted = false;

    /* === FUNCTIONS ========================== */
    function scatterPoint(): void {
        points[scatterIndex] = {
            x: Math.random() * 100,
            y: Math.random() * 100
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

    :global {
        :root {
            // variables
            --border-width: 1px;
            --border-thick-width: 2px;
            --trans-fast: 0.15s;
            --trans-normal: 0.2s;
            --trans-slow: 0.25s;
            --trans-cubic-1: cubic-bezier(0, .36, .34, 1);
            --controls-height: 50px;
            --controls-bottom: 10px;

            // colors
            --clr-bg: #f7f5ee;
            --clr-red: #c1272d;
            --clr-line: #d3d3d1;
            --clr-controls-text: #ffffff;
            --clr-controls-bg: #666666;
            --clr-controls-bg-hover: #585858;
            --clr-controls-bg-active: #474747;
        }

        *, *::before, *::after {
            font-family: 'General Sans', sans-serif;
        }
    }

    main {
        height: 100vh;
        background-color: var(--clr-bg);
        overflow: hidden;
    }

    .canvas {
        position: relative;
        height: calc(100vh - var(--controls-height) - var(--controls-bottom));
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

                    border: solid var(--border-width) var(--clr-controls-bg);
                }
            }
        }

        .origin {
            transition: transform var(--trans-normal) var(--trans-cubic-1);

            div {
                width: $_origin-size;
                height: $_origin-size;

                background-color: var(--clr-bg);
                border: solid var(--border-thick-width) var(--clr-red);
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

            transition: transform var(--trans-normal) var(--trans-cubic-1),
                        opacity var(--trans-fast) ease-in-out;

            &.shown {
                opacity: 1;
            }

            div {
                width: $_point-size;
                height: $_point-size;

                background-color: var(--clr-controls-bg);
                margin: calc(-0.5 * $_point-size) 0 0 calc(-0.5 * $_point-size);

                &::before {
                    top: $_point-border-offset;
                    right: $_point-border-offset;
                    bottom: $_point-border-offset;
                    left: $_point-border-offset;
                }
            }
        }
    }
</style>