<script lang="ts">
    /* === PROPS ============================== */
    export let value: number; // bind
    export let id: string;
    export let min: number;
    export let max: number;
    export let step: number;
</script>



<div class="container">
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
    $_thumb-width: 1.5px;

    .container {
        position: relative;
        height: var(--slider-height);
        border-bottom: solid var(--border-width) #3f3f3f;
    }
    
    input {
        // internal variables
        --_margin-hrz: calc(((100% - 22px) / 12 - #{$_thumb-width}) / 2);
        --_clr-thumb: rgb(255, 149, 149);
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
        transition: outline-color var(--trans-fast) ease;

        &:focus-visible {
            outline-color: red;
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
            box-shadow: 0 0 3px 1px red,
                        0 0 15px red;
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
            box-shadow: 0 0 3px 1px red,
                        0 0 15px red;
        }
    }

    label {
        display: flex;
        align-items: center;
        justify-content: center;
        position: absolute;
        inset: 0;
    }
</style>