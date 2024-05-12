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
</script>



<div
    class="shape"
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
                on:change={() => dispatch("shapeChange", {
                    neighborhoodIndex: index,
                    cellIndex: i,
                })} />
            <label
                for="shapeCell-{index}-{i}"
                class="label">
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
                on:change={() => dispatch("shapeChange", {
                    neighborhoodIndex: index,
                    cellIndex: i + neighborhoodCenterIndex + 1,
                })} />
            <label
                for="shapeCell-{index}-{i + neighborhoodCenterIndex + 1}"
                class="label">
                <span class="visuallyHidden">
                    {(i + neighborhoodCenterIndex + 1) % neighborhoodSideLength - neighborhoodMidpoint} x, {Math.floor((i + neighborhoodCenterIndex + 1) / neighborhoodSideLength) - neighborhoodMidpoint} y cell.
                </span>
            </label>
        </div>
    {/each}
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

        .cell {
            width: 100%;
            border-right: $_border-thin;
            border-bottom: $_border-thin;

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
</style>