<script lang="ts">
    /* === IMPORTS ============================ */
    import Lock from "$lib/SVGs/PXL-lock.svelte";

    /* === PROPS ============================== */
    export let id: string;
    export let locked: boolean; // bind
</script>



<div class="lockInput">
    <input
        type="checkbox"
        {id}
        class="visuallyHidden"
        bind:checked={locked} />
    <label for={id} class="iconButton">
        <Lock {locked} />
        <span class="visuallyHidden">
            <slot />
        </span>
    </label>
</div>



<style lang="scss">
    .lockInput {
        input {
            &:focus-visible + .iconButton,
            &:active + .iconButton {
                color: var(--PXL-clr-bg);
                background-color: var(--PXL-clr-900);
            }
        }

        .iconButton {
            display: block;
            cursor: pointer;
        }
    }
</style>