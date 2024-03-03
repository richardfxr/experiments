<script lang="ts">
    /* === PROPS ============================== */
    export let name: string;
    export let value: number; // bind
    export let min: number;
    export let max: number;
    export let step: number;
</script>



<label class="sliderWrapper">
    <div class="text">
        <span><slot /></span>
        <span class="value">{value}</span>
    </div>
    <input
        type="range"
        {name}
        bind:value={value}
        {min}
        {max}
        {step}
        on:change>
</label>



<style lang="scss">
    /* === INTERNAL VARIABLES ================= */
    $_track-width: 100%;
    $_track-height: 1px;
    $_thumb-height: 25px;
    $_thumb-width: 7px;
    $_clip-top: calc(($_thumb-height - $_track-height) * 0.5);
    $_clip-bottom: calc($_thumb-height - $_clip-top);
    $_clip-further: calc(100% + 1px);

    /* === MAIN STYLES ======================== */
    .sliderWrapper {
        // internal variables
        --_clr-track: var(--PXL-clr-border);
        --_clr-track-progress: var(--PXL-clr-800);
        --_clr-thumb: var(--PXL-clr-800);

        display: flex;
        flex-flow: column nowrap;
        gap: 5px;
        position: relative;
        width: 100%;

        padding: var(--PXL-input-pad-vrt) var(--PXL-controls-pad-hrz);

        &:hover, &:focus, &:focus-within {
            // internal variables
            --_clr-track: var(--PXL-clr-400);

            background-color: var(--PXL-clr-100);

            .text {
                color: var(--PXL-clr-900);
            }
        }

        .text {
            display: flex;
            flex-flow: row wrap;
            justify-content: space-between;

            .value {
                font-weight: 600;
            }
        }
    }
    
    input {
        // reset all styling
        -webkit-appearance: none;
        appearance: none;
        background: transparent;
        cursor: pointer;

        display: block;
        width: $_track-width;
        overflow: hidden;

        outline: solid 1px transparent;

        transition: opacity var(--PXL-trans-fast),
                    outline-color var(--PXL-trans-fast);

        &:focus, &:focus-visible {
            // internal variables
            --_clr-track-progress: var(--PXL-clr-900);
            --_clr-thumb: var(--PXL-clr-900);
        }

        &:focus-visible {
            outline-color: var(--clr-1000);
        }
        
        &::-webkit-slider-runnable-track {
            position: relative;
            height: $_thumb-height;
            background: linear-gradient(var(--_clr-track) 0 0) scroll no-repeat center /
                        100% calc($_track-height);
        }

        &::-webkit-slider-thumb {
            // reset styling
            -webkit-appearance: none;
            
            position: relative;
            width: $_thumb-width;
            height: $_thumb-height;

            // box-shadow and clip-path to fake progress color
            background: linear-gradient(var(--_clr-track-progress) 0 0) scroll no-repeat left center /
                        50% calc($_track-height + 1px);
            background-color: var(--_clr-thumb);
            box-shadow: calc(-100vmax - $_thumb-width) 0 0 100vmax var(--_clr-track-progress);

            clip-path: polygon(
                100% -1px,
                0 -1px,
                0 $_clip-top,
                -100vmax $_clip-top,
                -100vmax $_clip-bottom,
                0 $_clip-bottom,
                0 100%,
                $_clip-further $_clip-further
            );
        }

        &::-moz-range-track {
            height: $_track-height;
            background-color: var(--_clr-track);
        }

        &::-moz-range-thumb {
            width: $_thumb-width;
            height: $_thumb-height;
            background-color: var(--_clr-thumb);
            border: none;
            border-radius: 0;
        }

        &::-moz-range-progress {
            height: $_track-height;
            background-color: var(--_clr-track-progress);
        }
    }
</style>