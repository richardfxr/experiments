<script lang="ts">
    /* === IMPORTS ============================ */
    import type { SvelteComponent } from "svelte";
    import {
        totalNeighborhoods,
        neighborhoodSideLength,
        neighborhoodSize,
    } from "$lib/MNCA-controls.svelte";
    import Canvas from "$lib/MNCA-canvas.svelte";
    import Controls from "$lib/MNCA-controls.svelte";
    import RuleIcon from "$lib/SVGs/MNCA-rule.svelte";

    /* === BINDINGS =========================== */
    let controls: SvelteComponent;
    let canvas: SvelteComponent;

    /* === CONSTANTS ========================== */
    // date values for true and false
    const TRUE = 255;
    const FALSE = 0;
    // final data used to create the uNeighborhoodData data texture
    const neighborhoodData = new Uint8Array(neighborhoodSize * (totalNeighborhoods + 1) * 4);

    /* === VARIABLES ========================== */
    let fps = 0;
    // whether the neighborhood is enabled or not
    let neighborhoodStates: boolean[] = Array(totalNeighborhoods).fill(true);
    // Multiple Neighborhood Cellular Automaton neighborhoods shapes
    // 224 element arrays (15 x 15)
    // true = cell is part of neighborhood, false otherwise
    let neighborhoodShapes: boolean[][] = [
        // neighborhood A
        [
            false, false, false, false, false,  true,  true,  true,  true,  true, false, false, false, false, false,
            false, false, false,  true,  true,  true,  true,  true,  true,  true,  true,  true, false, false, false,
            false, false,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true, false, false,
            false,  true,  true,  true,  true, false, false, false, false, false,  true,  true,  true,  true, false,
            false,  true,  true,  true, false, false, false, false, false, false, false,  true,  true,  true, false,
             true,  true,  true, false, false, false, false, false, false, false, false, false,  true,  true,  true,
             true,  true,  true, false, false, false, false, false, false, false, false, false,  true,  true,  true,
             true,  true,  true, false, false, false, false, false, false, false, false, false,  true,  true,  true,
             true,  true,  true, false, false, false, false, false, false, false, false, false,  true,  true,  true,
             true,  true,  true, false, false, false, false, false, false, false, false, false,  true,  true,  true,
            false,  true,  true,  true, false, false, false, false, false, false, false,  true,  true,  true, false, 
            false,  true,  true,  true,  true, false, false, false, false, false,  true,  true,  true,  true, false,
            false, false,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true, false, false,
            false, false, false,  true,  true,  true,  true,  true,  true,  true,  true,  true, false, false, false,
            false, false, false, false, false,  true,  true,  true,  true,  true, false, false, false, false, false
        ],
        // neighborhood B
        [
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false,  true,  true,  true, false, false, false, false, false, false,
            false, false, false, false, false,  true,  true,  true,  true,  true, false, false, false, false, false,
            false, false, false, false,  true,  true,  true,  true,  true,  true,  true, false, false, false, false,
            false, false, false, false,  true,  true,  true, false,  true,  true,  true, false, false, false, false,
            false, false, false, false,  true,  true,  true,  true,  true,  true,  true, false, false, false, false,
            false, false, false, false, false,  true,  true,  true,  true,  true, false, false, false, false, false,
            false, false, false, false, false, false,  true,  true,  true, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false
        ],
        // neighborhood C
        [
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false,  true,  true,  true, false, false, false, false, false, false,
            false, false, false, false, false,  true,  true,  true,  true,  true, false, false, false, false, false,
            false, false, false, false, false,  true,  true, false,  true,  true, false, false, false, false, false,
            false, false, false, false, false,  true,  true,  true,  true,  true, false, false, false, false, false,
            false, false, false, false, false, false,  true,  true,  true, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false
        ],
        // neighborhood D
        [
            false, false, false, false, false,  true,  true,  true,  true,  true, false, false, false, false, false,
            false, false, false,  true,  true,  true,  true,  true,  true,  true,  true,  true, false, false, false,
            false, false,  true,  true,  true, false, false, false, false, false,  true,  true,  true, false, false,
            false,  true,  true,  true, false, false, false, false, false, false, false,  true,  true,  true, false,
            false,  true,  true, false, false, false, false, false, false, false, false, false,  true,  true, false,
             true,  true, false, false, false, false, false, false, false, false, false, false, false,  true,  true,
             true,  true, false, false, false, false, false, false, false, false, false, false, false,  true,  true, 
             true,  true, false, false, false, false, false, false, false, false, false, false, false,  true,  true, 
             true,  true, false, false, false, false, false, false, false, false, false, false, false,  true,  true,
             true,  true, false, false, false, false, false, false, false, false, false, false, false,  true,  true,
            false,  true,  true, false, false, false, false, false, false, false, false, false,  true,  true, false,
            false,  true,  true,  true, false, false, false, false, false, false, false,  true,  true,  true, false,
            false, false,  true,  true,  true, false, false, false, false, false,  true,  true,  true, false, false,
            false, false, false,  true,  true,  true,  true,  true,  true,  true,  true,  true, false, false, false,
            false, false, false, false, false,  true,  true,  true,  true,  true, false, false, false, false, false
        ]
    ];

    initializeNeighborhoodData();

    /* === FUNCTIONS ========================== */
    /* initialize all values for neighborhoodData based on neighborhoodShapes and neighborhoodRules */
    function initializeNeighborhoodData(): void {
        for (let y = 0; y < neighborhoodSideLength; y++) {
            for (let x = 0; x < neighborhoodSideLength; x++) {
                // get indices for cell
                const cellIndex = y * neighborhoodSideLength + x;
                const rowCellsBefore = y * neighborhoodSideLength * (totalNeighborhoods + 1);
                const columnCellsBefore = x;
                const dataIndex = (rowCellsBefore + columnCellsBefore) * 4;

                // TRUE: cell is part of neighborhood
                // FALSE: cell is not part of neighborhood
                neighborhoodData[dataIndex] = neighborhoodShapes[0][cellIndex] ? TRUE : FALSE;
                neighborhoodData[dataIndex + 1] = neighborhoodShapes[1][cellIndex] ? TRUE : FALSE;
                neighborhoodData[dataIndex + 2] = neighborhoodShapes[2][cellIndex] ? TRUE : FALSE;
                neighborhoodData[dataIndex + 3] = neighborhoodShapes[3][cellIndex] ? TRUE : FALSE;
            }
        }
    }

    function handleStateChange(neighborhoodIndex: number): void {
        for (let y = 0; y < neighborhoodSideLength; y++) {
            for (let x = 0; x < neighborhoodSideLength; x++) {
                // get indices for cell
                const rowCellsBefore = y * neighborhoodSideLength * (totalNeighborhoods + 1);
                const columnCellsBefore = x;
                const dataIndex = (rowCellsBefore + columnCellsBefore) * 4;

                if (neighborhoodStates[neighborhoodIndex]) {
                    // set appropriate value based on neighborhood shape
                    const cellIndex = y * neighborhoodSideLength + x;
                    neighborhoodData[dataIndex + neighborhoodIndex] =
                        neighborhoodShapes[neighborhoodIndex][cellIndex] ? TRUE : FALSE;
                } else {
                    // set to false as neighborhood is disabled
                    neighborhoodData[dataIndex + neighborhoodIndex] = FALSE;
                }
            }
        }

        if (canvas) canvas.updateNeighborhoods();
    }

    /* returns the neighborhoodData index of for cell in neighborhood */
    function getDataIndexOf(neighborhoodIndex: number, cellIndex: number, isRule = false): number {
        const offset = isRule ? neighborhoodIndex + 1 : 0;
        const rowCellsBefore = Math.floor(cellIndex / neighborhoodSideLength) * neighborhoodSideLength * (totalNeighborhoods + 1);
        const columnCellsBefore = cellIndex % neighborhoodSideLength + offset * neighborhoodSideLength;
        return (rowCellsBefore + columnCellsBefore) * 4;
    }

    function handleShapeChange(neighborhoodIndex: number, cellIndex: number): void {
        if (!neighborhoodStates[neighborhoodIndex]) return;
        const dataIndex = getDataIndexOf(neighborhoodIndex, cellIndex);
        // update green channel (shape of neighborhood) for corresponding cell
        neighborhoodData[dataIndex + neighborhoodIndex] = neighborhoodShapes[neighborhoodIndex][cellIndex] ? TRUE : FALSE;
        if (canvas) canvas.updateNeighborhoods();
    }
</script>



<main>
    <button
        class="rule"
        on:click={controls.showModal}>
        <RuleIcon />
        Rules
    </button>
    <Controls
        {fps}
        bind:neighborhoodStates={neighborhoodStates}
        bind:neighborhoodShapes={neighborhoodShapes}
        bind:this={controls}
        on:stateChange={e => handleStateChange(e.detail.neighborhoodIndex)}
        on:shapeChange={e => handleShapeChange(
            e.detail.neighborhoodIndex,
            e.detail.cellIndex
        )} />
    <Canvas
        bind:fps={fps}
        {neighborhoodData}
        bind:this={canvas} />
</main>



<style lang="scss">
    :root {
        // variables
        --MNCA-clr-1000: #FFFFFF;
        --MNCA-clr-600: #a5a5a5;
        --MNCA-clr-red: #FF7557;
        --MNCA-clr-bg: #000000;

        color-scheme: dark;
    }

    :global{
        .icon {
            display: block;

            .stroke {
                fill: none;
                stroke: currentColor;
                stroke-width: 1px;
                stroke-miterlimit: 10;
            }
        }
    }

    main {
        height: 100vh;

        color: var(--MNCA-clr-1000);
        font-family: "JetBrains Mono", monospace;
        font-size: 1rem;
    }

    button.rule {
        display: flex;
        flex-flow: row nowrap;
        align-items: center;
        gap: 6px;
        position: fixed;
        right: 8px;
        bottom: 8px;
        z-index: 1;

        color: var(--MNCA-clr-1000);
        font-weight: 700;
        text-transform: uppercase;
        padding: 8px 13px;
        background-color: var(--MNCA-clr-bg);
    }
</style>