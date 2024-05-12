<script lang="ts">
    /* === IMPORTS ============================ */
    import {
        neighborhoodSideLength,
        neighborhoodCenterIndex,
        neighborhoodLetters
    } from '$lib/MNCA-controls.svelte';

    /* === PROPS ============================== */
    export let neighborhoodIndex: number;
    export let neighborhoodShape: boolean[];
    export let enabled: boolean;
</script>



<svg
    class="neighborhoodPreview"
    class:enabled
    role="img"
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 15 15">
    <title>Neighborhood {neighborhoodLetters[neighborhoodIndex]} with {neighborhoodShape.filter(Boolean).length} cells.</title>
    {#each neighborhoodShape.slice(0 , neighborhoodCenterIndex) as cell, i}
        <rect
            class:live={cell}
            x={i % neighborhoodSideLength}
            y={Math.floor(i / neighborhoodSideLength)}
            width="1"
            height="1" />
    {/each}

    <!-- center cell -->
    <rect
        class="center"
        x="7"
        y="7"
        width="1"
        height="1" />

    {#each neighborhoodShape.slice(neighborhoodCenterIndex + 1) as cell, i}
        <rect
            class:live={cell}
            x={(i + neighborhoodCenterIndex + 1) % neighborhoodSideLength}
            y={Math.floor((i + neighborhoodCenterIndex + 1) / neighborhoodSideLength)}
            width="1"
            height="1" />
    {/each}
</svg>



<style lang="scss">
    .neighborhoodPreview {
        display: block;
        width: 100%;

        rect, rect.live, rect.center {
            fill: transparent;
        }

        &.enabled {
            rect {
                fill: transparent;

                &.live {
                    fill: currentColor;
                }

                &.center {
                    fill: var(--MNCA-clr-red);
                }
            }
        }
    }
</style>