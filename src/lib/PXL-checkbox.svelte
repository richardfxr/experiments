<script lang="ts">
    /* === PROPS ============================== */
    export let id: string;
    export let value: boolean; // bind
</script>



<div class="checkboxInput" id={id + "-wrapper"}>
    <input type="checkbox" class="visuallyHidden" {id} bind:checked={value} />
    <label for={id}>
        <div class="checkbox"></div>
        <slot />
    </label>
</div>



<style lang="scss">
    /* === INTERNAL VARIABLES ================= */
    $_checkbox-size: 20px;
    $_checkbox-fill-gap: 2px;

    /* === MAIN STYLES ======================== */
    .checkboxInput {
        position: relative;
        
        input {
            &:focus-visible + label, &:active + label {
                // internal variables
                --_clr-checkbox-border: var(--PXL-clr-bg);
                --_clr-ckeckbox-fill: var(--PXL-clr-800);

                color: var(--PXL-clr-bg);
                background-color: var(--PXL-clr-900);
            }

            &:checked {
                & + label {
                    // internal variables
                    --_clr-ckeckbox-fill: var(--PXL-clr-800);
                }

                &:focus-visible + label, &:active + label {
                    // internal variables
                    --_clr-ckeckbox-fill: var(--PXL-clr-bg);
                }
            }
        }

        label {
            // internal variables
            --_clr-checkbox-border: var(--PXL-clr-700);
            --_clr-ckeckbox-fill: var(--PXL-clr-bg);

            display: flex;
            flex-flow: row wrap;
            align-items: center;
            gap: 10px;
            min-width: $input-minSize;
            min-height: $input-minSize;

            padding: var(--PXL-input-pad-vrt) var(--PXL-controls-pad-hrz);
            background-color: var(--PXL-clr-bg);

            transition: color var(--PXL-trans-fast),
                        background-color var(--PXL-trans-fast);
            cursor: pointer;

            &:hover, &:focus {
                color: var(--PXL-clr-900);
                background-color: var(--PXL-clr-100);
            }

            .checkbox {
                position: relative;
                width: $_checkbox-size;
                height: $_checkbox-size;

                border: solid var(--PXL-border-width) var(--_clr-checkbox-border);

                transition: border-color var(--PXL-trans-fast);

                &::before {
                    content: "";
                    position: absolute;
                    top: $_checkbox-fill-gap;
                    right: $_checkbox-fill-gap;
                    bottom: $_checkbox-fill-gap;
                    left: $_checkbox-fill-gap;
                    background-color: var(--_clr-ckeckbox-fill);

                    transition: background-color var(--PXL-trans-fast);
                }
            }
        }
    }
</style>