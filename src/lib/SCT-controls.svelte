<script lang="ts">
    /* === PROPS ============================== */
    export let numPoints: number; // bind
    export let minPoints: number;
    export let maxPoints: number;
    export let scatterIndex: number;
    export let scattered: boolean
</script>



<div class="controls">
    <button>
        <div class="wrapper">
            <span id="scatter">scatter</span>
            <span id="numPoints">{numPoints}</span>
            <span id="points">{numPoints === 1 ? "point" : "points"}</span>
        </div>
    </button>

    <div class="pointSelect">
        <input
            type="range"
            id="rangeInput"
            name="points"
            bind:value={numPoints}
            on:input
            min={minPoints}
            max={maxPoints}
            step="1">
        <div class="blocks">
            {#each {length: maxPoints} as _, i (i)}
                <div class="block" class:shown={i < numPoints && (scattered || i < scatterIndex)}></div>
            {/each}
        </div>
    </div>
</div>



<style lang="scss">
    // === INTERNAL VARIABLES =====================
    $_controls-maxWidth: 400px;
    $_outline-offset: 1px;
    $_translateY: calc(-100% + var(--border-width));
    // range input
    $_track-width: 100%;
    $_thumb-width: 7px;
    $_thumb-height: 7px;
    $_thumb-margin-bottom: 7px;
    $_thumb-clip-top: calc(var(--controls-height) - ($_thumb-height + $_thumb-margin-bottom));
    $_thumb-clip-bottom: calc(var(--controls-height) - $_thumb-margin-bottom);

    .controls {
        display: flex;
        gap: 3px;
        position: fixed;
        bottom: 10px;
        left: 50%;
        width: calc(100% - 20px);
        height: var(--controls-height);
        max-width: $_controls-maxWidth;
        z-index: 2;

        margin-left: calc(-0.5 * min(calc(100% - 20px), $_controls-maxWidth));
    }

    button {
        outline: solid var(--border-thick-width) transparent;
        outline-offset: $_outline-offset;

        overflow: hidden;

        &:hover, &:focus {
            .wrapper {
                background-color: var(--clr-controls-bg-hover);
            }
        }

        &:active .wrapper {
            background-color: var(--clr-controls-bg-active);
        }

        &:focus-visible {
            outline-color: var(--clr-red);
        }

        .wrapper {
            display: grid;
            grid-template-columns: 1fr 2ch;
            grid-template-rows: auto;
            grid-template-areas:
                "scatter numPoints"
                "points numPoints";
            align-items: center;
            height: 100%;

            font-size: 36px;
            color: var(--clr-controls-text);
            padding: 0 6px;
            background-color: var(--clr-controls-bg);

            transition: background-color var(--trans-fast) ease-in-out;
            animation: slideDown var(--trans-normal) var(--trans-cubic-1) 1;
        }

        #scatter, #points {
            font-size: 14px;
            font-weight: 600;
            text-align: start;
            text-transform: uppercase;
            line-height: 1em;
        }

        #scatter {
            align-self: end;
            grid-area: scatter;
        }

        #numPoints {
            grid-area: numPoints;
            justify-self: end;
            font-weight: 200;
            line-height: 1em;
            padding-bottom: 0.05em; // alignment compensation
        }

        #points {
            align-self: start;  
            grid-area: points;
        }
    }

    .pointSelect {
        flex-grow: 1;
        position: relative;

        &:hover, &:focus-within {
            .blocks .block::before {
                background-color: var(--clr-controls-bg-hover);
            }
        }

        #rangeInput {
            // internal variables
            --_margin-hrz: calc(((100% - 22px) / 12 - #{$_thumb-width}) / 2);
            --_clr-thumb: var(--clr-controls-text);
            --_track-height: var(--border-width);

            // reset all styling
            -webkit-appearance: none;
            appearance: none;
            background: transparent;
            cursor: pointer;

            display: block;
            position: relative;
            width: $_track-width;
            height: 100%;
            z-index: 2;

            padding: 0 var(--_margin-hrz) 0 var(--_margin-hrz);
            margin: 0;

            outline: solid var(--border-thick-width) transparent;
            outline-offset: $_outline-offset;

            overflow: hidden;
            transition: opacity var(--trans-slow) var(--trans-cubic-1),
                        outline-color var(--trans-fast) ease;

            // load state
            // opacity: 0;

            &:focus-visible {
                outline-color: var(--clr-red);
            }
            
            &::-webkit-slider-runnable-track {
                position: relative;
                height: var(--_thumb-height);
                background: linear-gradient(var(--_clr-track) 0 0) scroll no-repeat center /
                            100% calc(var(--_track-height));
            }

            &::-webkit-slider-thumb {
                // reset styling
                -webkit-appearance: none;
                
                position: relative;
                width: $_thumb-width;
                height: var(--controls-height);

                background-color: var(--_clr-thumb);

                clip-path: polygon(
                    0 $_thumb-clip-top,
                    100% $_thumb-clip-top,
                    100% $_thumb-clip-bottom,
                    0 $_thumb-clip-bottom
                );
            }

            &::-moz-range-track {
                height: var(--_track-height);
                background-color: var(--_clr-track);
            }

            &::-moz-range-thumb {
                width: $_thumb-width;
                height: var(--controls-height);
                background-color: var(--_clr-thumb);
                border: none;
                border-radius: 0;

                clip-path: polygon(
                    0 $_thumb-clip-top,
                    100% $_thumb-clip-top,
                    100% $_thumb-clip-bottom,
                    0 $_thumb-clip-bottom
                );
            }
        }

        .blocks {
            display: flex;
            flex-flow: row nowrap;
            gap: 1px;
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            z-index: 1;

            .block {
                flex-grow: 1;
                position: relative;
                height: 100%;
                overflow: hidden;

                &::before {
                    content: "";
                    position: absolute;
                    top: 0;
                    right: 0;
                    bottom: 0;
                    left: 0;
                    background-color: var(--clr-controls-bg);

                    transform: translateY($_translateY);

                    transition: background-color var(--trans-fast) ease-in-out,
                                transform var(--trans-normal) var(--trans-cubic-1);
                }

                &.shown::before {
                    transform: translateY(0);
                }

                // unused load animation
                // @for $i from 1 through 8 {
                //     &:nth-child(#{$i})::before {
                //         animation: slideDown var(--trans-normal) var(--trans-cubic-1) 1;
                //         animation-fill-mode: backwards;
                //         animation-delay: calc($i * 50ms);
                //     }
                // }
            }
        }
    }
    
    // === KEYFRAMES ==============================
    @keyframes slideDown {
        from {
            transform: translateY($_translateY);
        }

        to {
            transform: translateY(0);
        }
    }
</style>