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
            .cross.line {
                &.primary, &.secondary {
                    stroke: var(--FCE-clr-bg);
                }
            }

            #eyes {
                opacity: 1;
                animation: moveEyes 2.3s cubic-bezier(.54,0,.46,1) infinite;
            }

            #pupils {
                animation: movePupils 2.3s cubic-bezier(.54,0,.46,1) infinite;
            }
        }

        .line {
            fill: none;
            stroke-width: 1px;
            transition: stroke var(--FCE-transition-fast);

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
            opacity: 0;
            transition: opacity var(--FCE-transition-fast);
        }
    }

    @media (prefers-motion-reduced: reduce) {
        svg {
            &.ready {
                #eyes, #pupils {
                    animation: none;
                }
            }
            
            .line {
                transition: none;
            }
        }
    }

    /* === ANIMATIONS ========================= */
    @keyframes moveEyes {
        from {
            transform: translate(-80px, -58px);
        }

        23% {
            transform: translate(-80px, -58px);
        }

        43% {
            transform: translate(93px, 73px);
        }

        57% {
            transform: translate(93px, 73px);
        }

        77% {
            transform: translate(-80px, -58px);
        }

        to {
            transform: translate(-80px, -58px);
        }
    }

    @keyframes movePupils {
        from {
            transform: translate(-8px, -12px);
        }

        16% {
            transform: translate(-11px, 6px);
        }

        27% {
            transform: translate(-11px, 6px);
        }

        43% {
            transform: translate(12px, 13px);
        }

        57% {
            transform: translate(12px, 13px);
        }

        77% {
            transform: translate(6px, -4px);
        }

        89% {
            transform: translate(-8px, -12px);
        }

        to {
            transform: translate(-8px, -12px);
        }
    }
</style>