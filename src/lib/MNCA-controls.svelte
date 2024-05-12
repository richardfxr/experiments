<script lang="ts" context="module">
    /* === TYPES ============================== */
    export type Rule = "noChange" | "death" | "birth";

    /* === CONSTANTS ========================== */
    export const totalNeighborhoods = 4;
    export const neighborhoodSideLength = 15; // width & height of each neighborhood, must be odd
    export const neighborhoodSize = neighborhoodSideLength ** 2;
    export const neighborhoodMidpoint = Math.floor(neighborhoodSideLength / 2);
    export const neighborhoodCenterIndex = Math.floor(neighborhoodSize / 2);
</script>



<script lang="ts">
    /* === IMPORTS ============================ */
    import { createEventDispatcher } from 'svelte';
    import State from "$lib/MNCA-state.svelte";
    import Shape from "$lib/MNCA-shape.svelte";
    import CloseIcon from "$lib/SVGs/MNCA-close.svelte";
    import CurrentCellIcon from "$lib/SVGs/MNCA-currentCell.svelte";

    /* === PROPS ============================== */
    export let fps: number;
    export let neighborhoodStates: boolean[]; // bind
    export let neighborhoodShapes: boolean[][]; // bind
    
    /* === BINDINGS =========================== */
    let dialog: HTMLDialogElement;

    /* === CONSTANTS ========================== */
    const dispatch = createEventDispatcher();
    const neighborhoodLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const neighborhoodDescs = [
        "Applies to the same color channel",
        "Applies to the same color channel",
        "Applies to the previous color channel",
        "Applies to the next color channel"
    ];

    /* === VARIABLES ========================== */
    let selectedNeighborhood = 0;

    /* === FUNCTIONS ========================== */
    export function showModal(): void {
        dialog.showModal();
    }

    function handleBackdropClick(e: MouseEvent): void {
        if (e.target !== dialog) return;
        dialog.close();
    }
</script>


<!-- on:click={handleBackdropClick} -->
<dialog
    class="controls"
    bind:this={dialog}>
    <form method="dialog">
        <div class="heading">
            <button
                type="submit"
                class="close">
                <CloseIcon />
                <span class="visuallyHidden">close</span>
            </button>
            <h1>Multiple Neighborhood Cellular Automaton</h1>
            <p
                class="fps"
                style="--_trans-x: -{Math.max((120 - fps) / 1.2, 0)}%">
                {fps} fps
            </p>
        </div>

        <div class="neighborhoods">
            <h2>Neighborhoods</h2>
            <div
                class="tabs"
                role="tablist"
                aria-labelledby="tablist-1">
                {#each {length: totalNeighborhoods} as _, i}
                    <button
                        id="tab-{i}"
                        class:selected={selectedNeighborhood === i}
                        type="button"
                        role="tab"
                        aria-selected={selectedNeighborhood === i}
                        aria-controls="tabpanel-{i}"
                        on:click={() => selectedNeighborhood = i}>
                        <span class="visuallyHidden">Neighborhood </span>
                        <span class="letter">{neighborhoodLetters[i]}</span>
                    </button>
                {/each}
            </div>
        </div>

        {#each {length: totalNeighborhoods} as _, i}
            <div
                id="tabpanel-{i}"
                class="neighborhood"
                class:hidden={selectedNeighborhood !== i}
                role="tabpanel"
                tabindex="0"
                aria-labelledby="tab-{i}">
                <div class="general">
                    <h2>Neighborhood {neighborhoodLetters[i]}</h2>
                    <p>{neighborhoodDescs[i]}</p>
                    <State
                        bind:state={neighborhoodStates[i]}
                        index={i}
                        on:stateChange={e => dispatch("stateChange", e.detail)} />
                </div>

                <div class="shape">
                    <h2>Shape</h2>
                    <p>Which neighboring cells are considered</p>
                    <ul class="legend" aria-label="legend">
                        <li>
                            <div class="cellIcon">
                                <CurrentCellIcon />
                            </div>
                            current cell
                        </li>
                        <li>
                            <div
                                class="cellIcon"
                                style="background-color: var(--MNCA-clr-1000);"
                                >
                                <span class="visuallyHidden">checked checkbox</span>
                            </div>
                            considered cell
                        </li>
                    </ul>
                    <Shape
                        bind:shape={neighborhoodShapes[i]}
                        index={i}
                        on:shapeChange={e => dispatch("shapeChange", e.detail)} />
                </div>
            </div>
        {/each}
        
        <div class="placeholder"></div>
    </form>
</dialog>



<style lang="scss">
    // internal variables
    $_border-thick-width: 1.5px;
    $_border-thick: solid $_border-thick-width var(--MNCA-clr-1000);
    $_border-thin-width: 1px;
    $_border-thin: solid $_border-thin-width var(--MNCA-clr-600);
    $_trans-fast: 0.2s ease-in-out;

    .controls {
        max-width: 500px;
        max-height: 100%;

        padding: 24px;
        border: none;
        margin: 0 0 0 auto;
        background-color: var(--MNCA-clr-bg);
        
        overflow-y: auto;

        &::backdrop {
            background-color: transparent;
        }

        .placeholder {
            height: 200vh;
        }

        h1, h2 {
            font-size: 1rem;
            font-weight: 700;
            text-transform: uppercase;
        }

        .heading {
            display: flex;
            flex-flow: column nowrap;

            button.close {
                align-self: flex-end;

                padding: 10px;
                border: $_border-thick;
                margin-bottom: 15px;
            }

            h1 {
                padding-bottom: 7px;
                border-bottom: $_border-thin;
            }

            .fps {
                // internal variables
                $_bar-height: 4px;

                position: relative;
                padding-top: calc($_bar-height + 2px);
                margin-top: 4px;
                overflow: hidden;

                &::before {
                    content: "";
                    position: absolute;
                    top: 0;
                    right: 0;
                    left: 0;
                    height: $_bar-height;
                    background-color: var(--MNCA-clr-1000);

                    transform: translateX(var(--_trans-x, -100%));
                    transition: transform $_trans-fast;
                }
            }
        }

        .neighborhoods {
            position: relative;
            // border compensation
            padding:
                $_border-thick-width
                calc($_border-thick-width - $_border-thin-width)
                calc($_border-thick-width - $_border-thin-width)
                $_border-thick-width;
            margin-top: 24px;

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
            
            h2 {
                padding: 2px 10px;
                border-bottom: $_border-thin;
            }

            .tabs {
                display: flex;
                flex-flow: row wrap;

                button {
                    display: flex;
                    flex-flow: column nowrap;
                    align-items: center;

                    padding: 10px 15px;
                    border-right: $_border-thin;
                    border-bottom: $_border-thin;

                    &.selected {
                        color: var(--MNCA-clr-bg);
                        background-color: var(--MNCA-clr-1000);
                    }

                    .letter {
                        display: block;
                        font-size: 3rem;
                        font-weight: 800;
                        line-height: 1em;
                    }
                }
            }
        }

        .neighborhood {
            display: flex;
            flex-flow: column nowrap;
            gap: 30px;

            margin-top: 30px;

            &.hidden {
                display: none;
            }

            .legend {
                display: flex;
                flex-flow: row wrap;
                gap: 18px;

                padding: 8px 0 8px 0;
                border-top: $_border-thin;
                margin-top: 5px;

                li {
                    display: flex;
                    flex-flow: row nowrap;
                    align-items: center;
                    gap: 7px;

                    .cellIcon {
                        display: block;
                        width: calc(18px + 2 * $_border-thick-width);
                        height: calc(18px + 2 * $_border-thick-width);
                        border: $_border-thick
                    }
                }
                
            }
        }
    }
</style>