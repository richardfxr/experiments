<script lang="ts">
    import Circle from "$lib/SVGs/SHD-circle.svelte";
    import Triangle from "$lib/SVGs/SHD-triangle.svelte";
    import Square from "$lib/SVGs/SHD-square.svelte";
    import Pentagon from "$lib/SVGs/SHD-pentagon.svelte";

    /* === PROPS ============================== */
    export let shape: number; // bind

    /* === CONSTANTS ========================== */
    const shapes = [
        { value: 1, name: "circle", svg: Circle },
        { value: 2, name: "triangle", svg: Triangle },
        { value: 3, name: "square", svg: Square },
        { value: 4, name: "pentagon", svg: Pentagon },
    ];
</script>



<h2 class="label" id="shapeLabel">shape</h2>

<div class="shapeRadios" role="radiogroup" aria-labelledby="shapeLabel">
    {#each shapes as iShape}
        <input
            id={"shapeRadio-" + iShape.value}
            type="radio"
            name={iShape.name}
            value={iShape.value}
            bind:group={shape}
        />
        <label
            for={"shapeRadio-" + iShape.value}
            class="label"
            class:active={shape === iShape.value}>
            <svelte:component this={iShape.svg} />
            <span class="visuallyHidden">{iShape.name}</span>
        </label>
    {/each}
</div>



<style lang="scss">
    .label {
        color: white;
        font-size: 1rem;
        font-weight: 400;
        text-align: center;
        margin-top: 12px;
    }

    .shapeRadios {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(80px, 1fr));
        gap: 10px;

        padding: 0 15px;
        border-bottom: solid var(--border-width) var(--border-clr);

        input {
            position: absolute;

            &:focus-visible + label {
                background-color: white;

                :global {
                    .shape .stroke {
                        stroke: black;
                    }
                }
            }
        }

        label {
            position: relative;
            cursor: pointer;
            padding: 12px 5px;

            transition: background-color 0.15s ease;

            &:hover, &:focus {
                :global {
                    .shape .stroke.main {
                        opacity: 0.85;
                    }
                }
            }

            &.active {
                :global {
                    .shape .stroke {
                        &.main {
                            opacity: 1;
                        }

                        &.second {
                            transform: scale(1);
                            opacity: 0.8;
                        }

                        &.third {
                            transform: scale(1);
                            opacity: 0.6;
                        }

                        &.fourth {
                            transform: scale(1);
                            opacity: 0.4;
                        }
                    }
                }
            }
        }

        :global {
        .shape {
            display: block;
            width: 100%;

            .stroke {
                fill: none;
                stroke: white;
                stroke-width: 1px;
                transform-origin: center;
                transition: stroke 0.15s ease,
                            transform 0.15s ease-out,
                            opacity 0.15s ease;

                &.main {
                    stroke-width: 2px;
                    opacity: 0.7;
                }

                &.second {
                    transform: scale(1.1);
                    opacity: 0;
                }

                &.third {
                    transform: scale(1.25);
                    opacity: 0;
                }

                &.fourth {
                    transform: scale(2);
                    opacity: 0;
                }
            }
        }
    }
    }
</style>