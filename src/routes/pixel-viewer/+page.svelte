<script lang="ts">
    /* === IMPORTS ============================ */
    import { writable } from 'svelte/store';
    // components
    import Canvas from "$lib/PXL-canvas.svelte";
    import Checkbox from "$lib/PXL-checkbox.svelte";
    import Controls from "$lib/PXL-controls.svelte";
    // SVGs
    import Mouse from '$lib/SVGs/PXL-mouse.svelte';
    import Trackpad from '$lib/SVGs/PXL-trackpad.svelte';
    import Hand from '$lib/SVGs/PXL-hand.svelte';
    import Settings from '$lib/SVGs/PXL-settings.svelte';

    /* === STORES ============================= */
    const showControls = writable(false);
    const lockPan = writable(false);
    const panXSensitivity = writable(1);
    const panYSensitivity = writable(1);
    const pinchZoomSensitivity = writable(0.23);
    const mouseZoomSensitivity = writable(1);
    const mouseZoomDirection = writable(false);
    const mouseZoomLimit = writable(7);
    const lockScroll = writable(false);
    const scrollXSensitivity = writable(1);
    const scrollXDirection = writable(false);
    const scrollYSensitivity = writable(1);
    const scrollYDirection = writable(false);
    const zoomWithCtrl = writable(true);

    /* === VARIABLES ========================== */
    let hasInteracted = false;

    /* === SUBSCRIPTIONS ====================== */
    showControls.subscribe((show) => {
        if (show) hasInteracted = true;
    });

    lockPan.subscribe((lock) => {
        if (lock && $panXSensitivity !== $panYSensitivity) {
            // sync both axes
            panYSensitivity.set($panXSensitivity);
        }   
    });

    panXSensitivity.subscribe((value) => {
        if ($lockPan && value !== $panYSensitivity) {
            panYSensitivity.set(value);
        }
    });

    panYSensitivity.subscribe((value) => {
        if ($lockPan && value !== $panXSensitivity) {
            panXSensitivity.set(value);
        }
    });

    lockScroll.subscribe((lock) => {
        if (lock && $scrollXSensitivity !== $scrollYSensitivity) {
            // sync sensitivity for both axes
            scrollYSensitivity.set($scrollXSensitivity);
        }
        if (lock && $scrollXDirection !== $scrollYDirection) {
            // sync direction for both axes
            scrollYDirection.set($scrollXDirection);
        }
    });

    scrollXSensitivity.subscribe((value) => {
        if ($lockScroll && value !== $scrollYSensitivity) {
            scrollYSensitivity.set(value);
        }
    });

    scrollXDirection.subscribe((direction) => {
        if ($lockScroll && direction !== $scrollYDirection) {
            scrollYDirection.set(direction);
        }
    });

    scrollYSensitivity.subscribe((value) => {
        if ($lockScroll && value !== $scrollXSensitivity) {
            scrollXSensitivity.set(value);
        }
    });

    scrollYDirection.subscribe((direction) => {
        if ($lockScroll && direction !== $scrollXDirection) {
            scrollXDirection.set(direction);
        }
    });
</script>



<main>
    <h1 class="visuallyHidden">Pixel Viewer</h1>

    {#if !hasInteracted}
        <div class="hint">
            <div>
                <p>Interact using:</p>
                <ul>
                    <li><Mouse /></li>
                    <li><Trackpad /></li>
                    <li><Hand /></li>
                </ul>
            </div>
        </div>
    {/if}

    <Canvas
        bind:hasInteracted={hasInteracted}
        panXSensitivity={$panXSensitivity}
        panYSensitivity={$panYSensitivity}
        pinchZoomSensitivity={$pinchZoomSensitivity}
        mouseZoomCoefficient={($mouseZoomDirection ? 1 : -1) * $mouseZoomSensitivity}
        mouseZoomLimit={$mouseZoomLimit}
        scrollXCoefficient={($scrollXDirection ? 1 : -1) * $scrollXSensitivity}
        scrollYCoefficient={($scrollYDirection ? 1 : -1) * $scrollYSensitivity}
        zoomWithCtrl={$zoomWithCtrl} />

    <Checkbox
        id="controlsInput"
        bind:value={$showControls}>
        <Settings />
        show controls
    </Checkbox>
    
    {#if $showControls}
        <Controls
            bind:showControls={$showControls}
            bind:lockPan={$lockPan}
            bind:panXSensitivity={$panXSensitivity}
            bind:panYSensitivity={$panYSensitivity}
            bind:pinchZoomSensitivity={$pinchZoomSensitivity}
            bind:mouseZoomSensitivity={$mouseZoomSensitivity}
            bind:mouseZoomDirection={$mouseZoomDirection}
            bind:mouseZoomLimit={$mouseZoomLimit}
            bind:zoomWithCtrl={$zoomWithCtrl}
            bind:lockScroll={$lockScroll}
            bind:scrollXSensitivity={$scrollXSensitivity}
            bind:scrollXDirection={$scrollXDirection}
            bind:scrollYSensitivity={$scrollYSensitivity}
            bind:scrollYDirection={$scrollYDirection} />
    {/if}
</main>



<style lang="scss">
    :root {
        // variables
        --PXL-clr-1000: #000000;
        --PXL-clr-900: #252525;
        --PXL-clr-800: #505050;
        --PXL-clr-700: #636363;
        --PXL-clr-600: #757575;
        --PXL-clr-400: #a5a5a5;
        --PXL-clr-100: #ebebeb;
        --PXL-clr-border: #c5c5c5;
        --PXL-clr-bg: #ffffff;

        --PXL-controls-pad-hrz: 16px;
        --PXL-controls-pad-vrt: 12px;
        --PXL-input-pad-vrt: 8px;

        --PXL-border-width: 1px;

        --PXL-trans-fast: 0.1s ease-in-out;
    }

    :global {
        body {
            color: var(--PXL-clr-700);
            font-family: 'General Sans', sans-serif;
            font-size: 1rem;
        }
        
        .iconButton {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: $input-minSize;
            min-width: $input-minSize;

            color: var(--PXL-clr-700);
            padding: var(--PXL-controls-pad-vrt) var(--PXL-controls-pad-hrz);
            background-color: transparent;

            transition: color var(--PXL-trans-fast),
                        background-color var(--PXL-trans-fast);

            &:hover, &:focus {
                color: var(--PXL-clr-900);
                background-color: var(--PXL-clr-100);
            }

            &:focus-visible, &:active {
                color: var(--PXL-clr-bg);
                background-color: var(--PXL-clr-900);
            }
        }
    }

    main {
        display: flex;
        flex-flow: row nowrap;
        align-items: stretch;

        .hint {
            display: flex;
            justify-content: center;
            position: fixed;
            right: 0;
            bottom: 20px;
            left: 0;
            z-index: 2;

            pointer-events: none;

            & > div {
                display: flex;
                flex-flow: row wrap;
                align-items: center;
                justify-content: center;
                gap: 10px;

                padding: var(--PXL-input-pad-vrt) var(--PXL-controls-pad-hrz);
                border: solid 1px var(--PXL-clr-border);
                margin: 0 10px;
                background-color: var(--PXL-clr-bg);
            }

            ul {
                display: flex;
                flex-flow: row nowrap;
                gap: 10px;
            }
        }

        :global {
            #controlsInput-wrapper {
                position: fixed;
                top: 10px;
                right: 10px;

                label {
                    font-weight: 500;
                    border: solid 1px var(--PXL-clr-border);

                    .checkbox {
                        display: none;
                    }
                }
            }
        }
    }
</style>