<script lang="ts">
    /* === PROPS ============================== */
    export let value: number; // bind
    export let id: string;
    export let min: number;
    export let max: number;
    export let step: number;
    export let thumbColor: string;
    export let shadowColor: string;
</script>



<div
    class="container"
    style="--_clr-thumb: {thumbColor}; --_clr-shadow: {shadowColor}">
    <input
        type="range"
        {id}
        name={id}
        {min}
        {max}
        {step}
        bind:value={value} />
    <label for={id} class="label">
        <span><slot /></span>
    </label>
</div>



<style lang="scss">
    // === INTERNAL VARIABLES =====================
    $_controls-maxWidth: 400px;
    $_outline-offset: 1px;
    $_translateY: calc(-100% + var(--border-width));
    // range input
    $_track-width: 100%;
    $_thumb-width: 2px;

    .container {
        position: relative;
        height: var(--slider-height);
        border-bottom: solid var(--border-width) var(--border-clr);
    }
    
    input {
        // internal variables
        --_margin-hrz: calc(((100% - 22px) / 12 - #{$_thumb-width}) / 2);
        --_track-height: 1px;

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

        margin: 0;

        outline: solid var(--border-thick-width) transparent;
        outline-offset: $_outline-offset;

        overflow: hidden;
        transition: background-color 0.15s ease;

        &:focus-visible {
            --_clr-thumb: black;

            background-color: white;

            & + label {
                color: black;
            }
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
            height: var(--slider-height);

            background-color: var(--_clr-thumb);
            box-shadow: 0 0 7px var(--_clr-shadow),
                        0 0 14px 4px var(--_clr-shadow);

            transition: background-color 0.15s ease;
        }

        &::-moz-range-track {
            height: var(--_track-height);
            background-color: var(--_clr-track);
        }

        &::-moz-range-thumb {
            width: $_thumb-width;
            height: var(--slider-height);
            background-color: var(--_clr-thumb);
            border: none;
            border-radius: 0;
            box-shadow: 0 0 7px var(--_clr-shadow),
                        0 0 12px 3px var(--_clr-shadow);

            transition: background-color 0.15s ease;
        }
    }

    .label {
        pointer-events: none;
        display: flex;
        align-items: center;
        justify-content: center;
        position: absolute;
        inset: 0;
        z-index: 3;

        transition: color 0.15s ease;

        &.outlined {
            z-index: 2;
            -webkit-text-stroke: 3px black;
        }
    }
</style>