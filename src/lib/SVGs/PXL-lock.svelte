<script lang="ts">
    /* === PROPS ============================== */
    export let locked: boolean;
</script>



<svg
    class:locked
    role="presentation"
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 22 22">
    <rect class="body" vector-effect="non-scaling-stroke" x="3" y="10" width="16" height="11"/>
    <line class="gap" vector-effect="non-scaling-stroke" x1="16" y1="6" x2="16" y2="10"/>
    <path class="shackle" vector-effect="non-scaling-stroke" d="M16,6c0-2.76-2.24-5-5-5s-5,2.24-5,5v4"/>
</svg>



<style lang="scss">
    svg {
        display: block;
        width: 22px;
        height: 22px;

        &.locked {
            .gap {
                stroke: currentColor;
            }

            .body {
                fill: currentColor;
            }
        }

        * {
            fill: none;
            stroke: currentColor;
            stroke-width: 1px;
        }

        .gap {
            stroke: none;
            transition: stroke var(--PXL-trans-fast);
        }

        .body {
            transition: fill var(--PXL-trans-fast);
        }
    }
</style>