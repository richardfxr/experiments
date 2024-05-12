<script lang="ts">
    /* === IMPORTS ============================ */
    import { createEventDispatcher } from 'svelte';
    import {
        neighborhoodSideLength,
        neighborhoodMidpoint,
        neighborhoodCenterIndex
    } from "$lib/MNCA-controls.svelte";
    import CurrentCellIcon from "$lib/SVGs/MNCA-currentCell.svelte";

    /* === PROPS ============================== */
    export let shape: boolean[]; // bind
    export let index: number;

    /* === CONSTANTS ========================== */
    const dispatch = createEventDispatcher();

    /* === VARIABLES ========================== */
    let draw = false;

    /* === FUNCTIONS ========================== */
    function handleDraw(event: PointerEvent, cellIndex: number): void {
        if (!draw || event.buttons !== 1) return;
        console.log("handleDraw");
        event.preventDefault();

        shape[cellIndex] = !shape[cellIndex];

        dispatch("shapeChange", {
            neighborhoodIndex: index,
            cellIndex
        });

        // release pointer capture for touch screens
        const label = document.getElementById(`shapeCell-${index}-${cellIndex}-label`);
        label?.releasePointerCapture(event.pointerId);
    }

    function handlePointerDown(event: PointerEvent, cellIndex: number): void {
        if (!draw) return;
        // release pointer capture for touch screens
        const label = document.getElementById(`shapeCell-${index}-${cellIndex}-label`);
        label?.releasePointerCapture(event.pointerId);
    }
</script>



<div
    class="shape"
    class:draw
    style="--_size: {neighborhoodSideLength};"
    role="radiogroup"
    aria-labelledby="shapeHeading-{index}">
    {#each shape.slice(0 , neighborhoodCenterIndex) as _, i}
        <div class="cell">
            <input
                type="checkbox"
                id="shapeCell-{index}-{i}"
                class="visuallyHidden"
                name="shapeCell-{index}-{i}"
                bind:checked={shape[i]}
                on:click={e => {if (draw) e.preventDefault();}}
                on:change={() => dispatch("shapeChange", {
                    neighborhoodIndex: index,
                    cellIndex: i,
                })} />
            <label
                for="shapeCell-{index}-{i}"
                id="shapeCell-{index}-{i}-label"
                class="label"
                on:pointerenter={e => handleDraw(e, i)}
                on:mousedown={e => handleDraw(e, i)}
                on:pointerdown={e => handlePointerDown(e, i)}>
                <span class="visuallyHidden">
                    {i % neighborhoodSideLength - neighborhoodMidpoint} x, {Math.floor(i / neighborhoodSideLength) - neighborhoodMidpoint} y cell.
                </span>
            </label>
        </div>
    {/each}

    <div class="center cell">
        <div class="label">
            <CurrentCellIcon />
        </div>
    </div>

    {#each shape.slice(neighborhoodCenterIndex + 1) as _, i}
        <div class="cell">
            <input
                type="checkbox"
                id="shapeCell-{index}-{i + neighborhoodCenterIndex + 1}"
                class="visuallyHidden"
                name="shapeCell-{index}-{i + neighborhoodCenterIndex + 1}"
                bind:checked={shape[i + neighborhoodCenterIndex + 1]}
                on:click={e => {if (draw) e.preventDefault();}}
                on:change={e => dispatch("shapeChange", {
                    neighborhoodIndex: index,
                    cellIndex: i + neighborhoodCenterIndex + 1,
                })} />
            <label
                for="shapeCell-{index}-{i + neighborhoodCenterIndex + 1}"
                id="shapeCell-{index}-{i + neighborhoodCenterIndex + 1}-label"
                class="label"
                on:pointerenter={e => handleDraw(
                    e,
                    i + neighborhoodCenterIndex + 1
                )}
                on:mousedown={e => handleDraw(
                    e,
                    i + neighborhoodCenterIndex + 1
                )}
                on:pointerdown={e => handlePointerDown(
                    e,
                    i + neighborhoodCenterIndex + 1
                )}>
                <span class="visuallyHidden">
                    {(i + neighborhoodCenterIndex + 1) % neighborhoodSideLength - neighborhoodMidpoint} x, {Math.floor((i + neighborhoodCenterIndex + 1) / neighborhoodSideLength) - neighborhoodMidpoint} y cell.
                </span>
            </label>
        </div>
    {/each}
</div>

<div
    class="mode"
    role="radiogroup"
    aria-label="checkbox mode">
    <div class="radio">
        <input
            type="radio"
            id="click-{index}"
            class="visuallyHidden"
            name="click-{index}"
            value={false}
            bind:group={draw} />
        <label
            for="click-{index}"
            class="title">
            Click
        </label>
    </div>
    <div class="radio">
        <input
            type="radio"
            id="draw-{index}"
            class="visuallyHidden"
            name="draw-{index}"
            value={true}
            bind:group={draw} />
        <label
            for="draw-{index}"
            class="title">
            Draw
        </label>
    </div>
</div>



<style lang="scss">
    // internal variables
    $_border-thick-width: 1.5px;
    $_border-thick: solid $_border-thick-width var(--MNCA-clr-1000);
    $_border-thin-width: 1px;
    $_border-thin: solid $_border-thin-width var(--MNCA-clr-600);
    $_trans-fast: 0.2s ease-in-out;

    .shape {
        display: grid;
        grid-template-columns: repeat(var(--_size), 1fr);
        position: relative;

        // border compensation
        padding:
            $_border-thick-width
            calc($_border-thick-width - $_border-thin-width)
            calc($_border-thick-width - $_border-thin-width)
            $_border-thick-width;

        &::before {
            // outer border
            content: "";
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            border: $_border-thick;
            pointer-events: none;
        }

        &.draw {
            touch-action: none;
        }

        .cell {
            width: 100%;
            border-right: $_border-thin;
            border-bottom: $_border-thin;

            &.center {
                background-color: var(--MNCA-clr-red);
            }

            input:checked + label {
                color: var(--MNCA-clr-bg);
                background-color: var(--MNCA-clr-1000);
            }

            .label {
                aspect-ratio: 1 / 1;
            }

            label {
                display: block;
                cursor: crosshair;
            }
        }
    }

    .mode {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(calc(8ch + 20px), 1fr));
        
        border: $_border-thick;
        margin-top: 8px;

        .radio {
            &:first-child {
                border-right: $_border-thin;
                margin-right: calc(-0.5 * $_border-thin-width);
            }

            input:checked + label {
                color: var(--MNCA-clr-bg);
                background-color: var(--MNCA-clr-1000);
            }

            label {
                display: block;

                font-size: 1rem;
                font-weight: 700;
                text-transform: uppercase;
                text-align: center;
                padding: 5px;

                cursor: pointer;
            }
        }
    }
</style>