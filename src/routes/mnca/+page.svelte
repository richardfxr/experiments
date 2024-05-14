<script lang="ts">
    /* === IMPORTS ============================ */
    import type { SvelteComponent } from "svelte";
    import {
        totalNeighborhoods,
        neighborhoodSideLength,
        neighborhoodSize,
        deafultNeighborhoodStates,
        defaultNeighborhoodShapes,
        defaultNeighborhoodRules,
        defaultNeighborhoodOverrideRules
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
    let neighborhoodStates = deafultNeighborhoodStates.map(e => e);
    // neighborhood shapes
    let neighborhoodShapes = defaultNeighborhoodShapes.map(e => e);
    // neighborhood rules
    let neighborhoodRules = defaultNeighborhoodRules.map(e => e);
    let neighborhoodOverrideRules = defaultNeighborhoodOverrideRules.map(e => e);

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

                // set neighborhood shape
                // TRUE: cell is part of neighborhood
                // FALSE: cell is not part of neighborhood
                const shapeIndex = (rowCellsBefore + columnCellsBefore) * 4;
                neighborhoodData[shapeIndex] = neighborhoodShapes[0][cellIndex] ? TRUE : FALSE;
                neighborhoodData[shapeIndex + 1] = neighborhoodShapes[1][cellIndex] ? TRUE : FALSE;
                neighborhoodData[shapeIndex + 2] = neighborhoodShapes[2][cellIndex] ? TRUE : FALSE;
                neighborhoodData[shapeIndex + 3] = neighborhoodShapes[3][cellIndex] ? TRUE : FALSE;

                for (let i = 0; i < totalNeighborhoods; i++) {
                    // set neighborhood default rules
                    // R: TRUE: cell states stays the same, FALSE: cell dies
                    // G: TRUE: cell is born, FALSE: no effect
                    // set neighborhood override rules
                    // B: TRUE: cell states stays the same, FALSE: cell dies
                    // A: TRUE: cell is born, FALSE: no effect
                    const rule = neighborhoodRules[i][cellIndex];
                    const overrideRule = neighborhoodOverrideRules[i][cellIndex];
                    const ruleIndex = (rowCellsBefore + neighborhoodSideLength + neighborhoodSideLength * i + columnCellsBefore) * 4;
                    switch (rule) {
                        case 0:
                            neighborhoodData[ruleIndex] = FALSE;
                            neighborhoodData[ruleIndex + 1] = FALSE;
                            break;
                        case 1:
                            neighborhoodData[ruleIndex] = FALSE;
                            neighborhoodData[ruleIndex + 1] = TRUE;
                            break;
                        case 2:
                            neighborhoodData[ruleIndex] = TRUE;
                            neighborhoodData[ruleIndex + 1] = FALSE;
                            break;
                    }
                    switch (overrideRule) {
                        case 0:
                            neighborhoodData[ruleIndex + 2] = FALSE;
                            neighborhoodData[ruleIndex + 3] = FALSE;
                            break;
                        case 1:
                            neighborhoodData[ruleIndex + 2] = FALSE;
                            neighborhoodData[ruleIndex + 3] = TRUE;
                            break;
                        case 2:
                            neighborhoodData[ruleIndex + 2] = TRUE;
                            neighborhoodData[ruleIndex + 3] = FALSE;
                            break;
                    }
                }
            }
        }
    }

    /* returns the neighborhoodData index of for cell in neighborhood */
    function getDataIndexOf(neighborhoodIndex: number, cellIndex: number, isRule = false): number {
        const offset = isRule ? neighborhoodIndex + 1 : 0;
        const rowCellsBefore = Math.floor(cellIndex / neighborhoodSideLength) * neighborhoodSideLength * (totalNeighborhoods + 1);
        const columnCellsBefore = cellIndex % neighborhoodSideLength + offset * neighborhoodSideLength;
        return (rowCellsBefore + columnCellsBefore) * 4;
    }

    function handleStateChange(neighborhoodIndex: number): void {
        const enabled = neighborhoodStates[neighborhoodIndex];

        // toggle neighborhood shape
        for (let y = 0; y < neighborhoodSideLength; y++) {
            for (let x = 0; x < neighborhoodSideLength; x++) {
                // get indices for cell
                const rowCellsBefore = y * neighborhoodSideLength * (totalNeighborhoods + 1);
                const columnCellsBefore = x;
                const dataIndex = (rowCellsBefore + columnCellsBefore) * 4;

                if (enabled) {
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

        // toggle neighborhood rules for 0 cells
        if (enabled) {
            // set rule to its actual value
            handleRuleChange(neighborhoodIndex, 0, false);
            handleRuleChange(neighborhoodIndex, 0, true);
        } else {
            // set both rules to 2 (cell will stay the same)
            const zeroRuleIndex = getDataIndexOf(neighborhoodIndex, 0, true);
            neighborhoodData[zeroRuleIndex] = TRUE;
            neighborhoodData[zeroRuleIndex + 1] = FALSE;
            neighborhoodData[zeroRuleIndex + 2] = TRUE;
            neighborhoodData[zeroRuleIndex + 3] = FALSE;
        }

        if (canvas) canvas.updateNeighborhoods();
    }

    function handleShapeChange(neighborhoodIndex: number, cellIndex: number): void {
        if (!neighborhoodStates[neighborhoodIndex]) return;
        const dataIndex = getDataIndexOf(neighborhoodIndex, cellIndex);
        neighborhoodData[dataIndex + neighborhoodIndex] = neighborhoodShapes[neighborhoodIndex][cellIndex] ? TRUE : FALSE;

        if (canvas) canvas.updateNeighborhoods();
    }

    function handleRuleChange(neighborhoodIndex: number, cellIndex: number, isOverride: boolean): void {
        if (!neighborhoodStates[neighborhoodIndex]) return;
        const dataIndex = getDataIndexOf(neighborhoodIndex, cellIndex, true);
        if (isOverride) {
            const overrideRule = neighborhoodOverrideRules[neighborhoodIndex][cellIndex];
            switch (overrideRule) {
                case 0:
                    neighborhoodData[dataIndex + 2] = FALSE;
                    neighborhoodData[dataIndex + 3] = FALSE;
                    break;
                case 1:
                    neighborhoodData[dataIndex + 2] = FALSE;
                    neighborhoodData[dataIndex + 3] = TRUE;
                    break;
                case 2:
                    neighborhoodData[dataIndex + 2] = TRUE;
                    neighborhoodData[dataIndex + 3] = FALSE;
                    break;
            }
        } else {
            const rule = neighborhoodRules[neighborhoodIndex][cellIndex];
            switch (rule) {
                case 0:
                    neighborhoodData[dataIndex] = FALSE;
                    neighborhoodData[dataIndex + 1] = FALSE;
                    break;
                case 1:
                    neighborhoodData[dataIndex] = FALSE;
                    neighborhoodData[dataIndex + 1] = TRUE;
                    break;
                case 2:
                    neighborhoodData[dataIndex] = TRUE;
                    neighborhoodData[dataIndex + 1] = FALSE;
                    break;
            }
        }

        if (canvas) canvas.updateNeighborhoods();
    }

    function handleClear(neighborhoodIndex: number): void {
        for (let y = 0; y < neighborhoodSideLength; y++) {
            for (let x = 0; x < neighborhoodSideLength; x++) {
                const rowCellsBefore = y * neighborhoodSideLength * (totalNeighborhoods + 1);
                const columnCellsBefore = x;

                // clear neighborhood shape
                const shapeIndex = (rowCellsBefore + columnCellsBefore) * 4;
                neighborhoodData[shapeIndex + neighborhoodIndex] = FALSE;

                // clear neighborhood rules
                const ruleIndex = (rowCellsBefore + neighborhoodSideLength + neighborhoodSideLength * neighborhoodIndex + columnCellsBefore) * 4;
                neighborhoodData[ruleIndex] = TRUE;
                neighborhoodData[ruleIndex + 1] = FALSE;
                neighborhoodData[ruleIndex + 2] = TRUE;
                neighborhoodData[ruleIndex + 3] = FALSE;
            }
        }
        
        if (canvas) canvas.updateNeighborhoods();
    }
    
    function handleReset(neighborhoodIndex: number): void {
        const enabled = neighborhoodStates[neighborhoodIndex];

        for (let y = 0; y < neighborhoodSideLength; y++) {
            for (let x = 0; x < neighborhoodSideLength; x++) {
                // get indices for cell
                const cellIndex = y * neighborhoodSideLength + x;
                const rowCellsBefore = y * neighborhoodSideLength * (totalNeighborhoods + 1);
                const columnCellsBefore = x;

                if (enabled) {
                    // set neighborhood shape
                    const shapeIndex = (rowCellsBefore + columnCellsBefore) * 4;
                    neighborhoodData[shapeIndex + neighborhoodIndex] = neighborhoodShapes[neighborhoodIndex][cellIndex] ? TRUE : FALSE;
                }

                // set neighborhood rules
                const rule = neighborhoodRules[neighborhoodIndex][cellIndex];
                const overrideRule = neighborhoodOverrideRules[neighborhoodIndex][cellIndex];
                const ruleIndex = (rowCellsBefore + neighborhoodSideLength + neighborhoodSideLength * neighborhoodIndex + columnCellsBefore) * 4;
                switch (rule) {
                    case 0:
                        neighborhoodData[ruleIndex] = FALSE;
                        neighborhoodData[ruleIndex + 1] = FALSE;
                        break;
                    case 1:
                        neighborhoodData[ruleIndex] = FALSE;
                        neighborhoodData[ruleIndex + 1] = TRUE;
                        break;
                    case 2:
                        neighborhoodData[ruleIndex] = TRUE;
                        neighborhoodData[ruleIndex + 1] = FALSE;
                        break;
                }
                switch (overrideRule) {
                    case 0:
                        neighborhoodData[ruleIndex + 2] = FALSE;
                        neighborhoodData[ruleIndex + 3] = FALSE;
                        break;
                    case 1:
                        neighborhoodData[ruleIndex + 2] = FALSE;
                        neighborhoodData[ruleIndex + 3] = TRUE;
                        break;
                    case 2:
                        neighborhoodData[ruleIndex + 2] = TRUE;
                        neighborhoodData[ruleIndex + 3] = FALSE;
                        break;
                }
            }
        }

        if (!enabled) {
            // set both rules to 2 (cell will stay the same)
            // if neighborhood is disabled
            const zeroRuleIndex = getDataIndexOf(neighborhoodIndex, 0, true);
            neighborhoodData[zeroRuleIndex] = TRUE;
            neighborhoodData[zeroRuleIndex + 1] = FALSE;
            neighborhoodData[zeroRuleIndex + 2] = TRUE;
            neighborhoodData[zeroRuleIndex + 3] = FALSE;
        }

        if (canvas) canvas.updateNeighborhoods();
    }
</script>



<main>
    <button
        class="rule"
        on:click={controls.showModal}>
        <RuleIcon />Rules
    </button>
    <Controls
        {fps}
        bind:neighborhoodStates={neighborhoodStates}
        bind:neighborhoodShapes={neighborhoodShapes}
        bind:neighborhoodRules={neighborhoodRules}
        bind:neighborhoodOverrideRules={neighborhoodOverrideRules}
        bind:this={controls}
        on:stateChange={e => handleStateChange(e.detail.neighborhoodIndex)}
        on:shapeChange={e => handleShapeChange(
            e.detail.neighborhoodIndex,
            e.detail.cellIndex
        )}
        on:ruleChange={e => handleRuleChange(
            e.detail.neighborhoodIndex,
            e.detail.cellIndex,
            e.detail.isOverride
        )}
        on:clear={e => handleClear(e.detail.neighborhoodIndex)}
        on:reset={e => handleReset(e.detail.neighborhoodIndex)}
        on:randomize={() => {if (canvas) canvas.randomizeCells()}}
        on:randomizeMono={() => {if (canvas) canvas.randomizeCellsMono()}} />
    <Canvas
        bind:fps={fps}
        {neighborhoodData}
        bind:this={canvas} />
</main>



<style lang="scss">
    :root {
        // variables
        --MNCA-clr-1000: #FFFFFF;
        --MNCA-clr-900: #eeeeee;
        --MNCA-clr-600: #b3b3b3;
        --MNCA-clr-100: #252525;
        --MNCA-clr-red: #FF7557;
        --MNCA-clr-red-hover: #ff8a70;
        --MNCA-clr-teal: #00BDA1;
        --MNCA-clr-teal-hover: #17d4b8;
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
        gap: 8px;
        position: fixed;
        right: 8px;
        bottom: 8px;
        z-index: 1;

        color: var(--MNCA-clr-1000);
        font-weight: 700;
        text-transform: uppercase;
        padding: 8px 13px;
        background-color: var(--MNCA-clr-bg);

        &:hover, &:focus {
            background-color: var(--MNCA-clr-100);
        }

        &:focus-visible {
            outline: 2px solid var(--MNCA-clr-1000);
        }

        &:active {
            color: var(--MNCA-clr-bg);
            background-color: var(--MNCA-clr-1000);
        }
    }
</style>