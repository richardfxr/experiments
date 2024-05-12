<script lang="ts">
    /* === IMPORTS ============================ */
    import { createEventDispatcher } from 'svelte';

    /* === PROPS ============================== */
    export let state: boolean; // bind
    export let index: number;

    /* === CONSTANTS ========================== */
    const dispatch = createEventDispatcher();
</script>



<div
    class="state"
    role="radiogroup"
    aria-label="state">
    <div class="radio">
        <input
            type="radio"
            id="enabled-{index}"
            class="visuallyHidden"
            name="enabled-{index}"
            value={true}
            bind:group={state}
            on:change={() => dispatch(
                "stateChange",
                { neighborhoodIndex: index }
            )} />
        <label
            for="enabled-{index}"
            class="title">
            Enabled
        </label>
    </div>
    <div class="radio">
        <input
            type="radio"
            id="disabled-{index}"
            class="visuallyHidden"
            name="disabled-{index}"
            value={false}
            bind:group={state}
            on:change={() => dispatch(
                "stateChange",
                { neighborhoodIndex: index }
            )} />
        <label
            for="disabled-{index}"
            class="title">
            Disabled
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

    .state {
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