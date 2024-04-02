<script lang="ts">
    /* === IMPORTS ============================ */
    import type { State } from "../../routes/face-detector/+page.svelte";

    /* === PROPS ============================== */
    export let state: State;
</script>



<svg
    class={state}
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 500 360">
    <line class="line secondary cross" vector-effect="non-scaling-stroke" y1="180" x2="500" y2="180"/>
    <line class="line secondary cross" vector-effect="non-scaling-stroke" x1="250" x2="250" y2="360"/>
    <line class="line primary cross" vector-effect="non-scaling-stroke" x2="500" y2="360"/>
    <line class="line primary cross" vector-effect="non-scaling-stroke" x1="500" y2="360"/>
    <g id="eyes">
        <rect class="line secondary" vector-effect="non-scaling-stroke" x="155" y="147.5" width="65" height="65"/>
        <rect class="line secondary" vector-effect="non-scaling-stroke" x="280" y="147.5" width="65" height="65"/>
        <g id="pupils">
            <rect class="fill primary" x="172.5" y="165" width="30" height="30"/>
            <rect class="fill primary" x="297.5" y="165" width="30" height="30"/>
        </g>
    </g>
</svg>



<style lang="scss">
    svg {
        display: block;
        width: 100%;
        max-width: 500px;
        border: solid 1px var(--FCE-clr-600);

        &.noWebcam, &.noContext, &.modelError {
            .line.primary.cross {
                stroke: var(--FCE-clr-1000);
            }
        }

        &.ready {
            .cross {
                display: none;
            }

            #eyes {
                display: block;
            }
        }

        .line {
            fill: none;
            stroke-width: 1px;

            &.primary {
                stroke: var(--FCE-clr-1000);
            }

            &.secondary {
                stroke: var(--FCE-clr-600);
            }
            
            &.primary.cross, &.secondary.cross {
                stroke: var(--FCE-clr-600);
            }
        }

        .fill.primary {
            fill: var(--FCE-clr-1000);
        }

        #eyes {
            display: none;
        }
    }
</style>