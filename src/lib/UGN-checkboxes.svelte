<script lang="ts">
    /* === PROPS ============================== */
    export let label: string;
    export let options: {label: string, value: string | number}[];
    export let selection: string[] | number[];
</script>


<div class="checkboxes">
    <p class="label">{label}</p>
    <div>
        {#each options as option}
            <div>
                <input
                    type="checkbox"
                    id={option.label}
                    class="visuallyHidden"
                    name={label}
                    bind:group={selection}
                    value={option.value}
                    disabled={selection.length === 1 && selection[0] === option.value}>
                <label for={option.label}>{option.label}</label>
            </div> 
        {/each}
    </div>
    
</div>


<style lang="scss">
    .checkboxes {
        // internal variables
        --_clr-border: #ffffff;
        --_border-radius: 5px;

        font-size: 1rem;

        & > div {
            display: flex;
            flex-flow: row wrap;
            gap: 8px;
        }
    }

    p.label {
        color: #5e5e5e;
        padding-bottom: 6px;
    }

    label {
        display: block;
        cursor: pointer;

        color: var(--_clr-800);

        padding: 5px 8px;
        border: solid 1px var(--_clr-border);
        border-radius: var(--_border-radius);
        background-color: transparent;

        transition: color 0.1s ease,
                    background-color 0.1s ease;

        &:hover {
            color: var(--_clr-900);
            background-color: var(--_clr-100);
        }
    }

    input {
        &:focus-visible + label {
            outline-offset: calc(-1 * var(--_focus-outline-width));
            outline: var(--_focus-outline);
        }

        &:checked + label {
            color: var(--_clr-1000);
            background-color: var(--_clr-0);
        }

        &:disabled + label {
            cursor: not-allowed;
        }
    }
</style>