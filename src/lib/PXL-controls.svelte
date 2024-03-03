<script lang="ts">
    /* === IMPORTS ============================ */
    import Cross from "$lib/SVGs/PXL-cross.svelte";
    import LockInput from '$lib/PXL-lockInput.svelte';
    import Slider from '$lib/PXL-slider.svelte';
    import Checkbox from "$lib/PXL-checkbox.svelte";
    import Reset from "$lib/SVGs/PXL-reset.svelte";

    /* === PROPS ============================== */
    export let showControls: boolean; // bind
    export let lockPan: boolean; // bind
    export let panXSensitivity: number; // bind
    export let panYSensitivity: number; // bind
    export let pinchZoomSensitivity: number; // bind
    export let mouseZoomSensitivity: number; // bind
    export let mouseZoomDirection: boolean; // bind
    export let mouseZoomLimit: number; // bind
    export let zoomWithCtrl: boolean; // bind
    export let lockScroll: boolean; // bind
    export let scrollXSensitivity: number; // bind
    export let scrollXDirection: boolean; // bind
    export let scrollYSensitivity: number; // bind
    export let scrollYDirection: boolean; // bind
</script>



<form>
    <div class="header">
        <div class="widthContainer headingWithButton">
            <h2>Controls</h2>
            <button
                type="button"
                class="iconButton"
                on:click={() => showControls = false}>
                <Cross />
                <span class="visuallyHidden">hide controls</span>
            </button>
        </div>
    </div>

    <div class="group" role="group" aria-labelledby="panning">
        <div class="widthContainer">
            <div class="headingWithButton">
                <h3 id="panning">Panning</h3>
                <LockInput bind:locked={lockPan} id="lockPan">
                    sync pan for both axes
                </LockInput>
            </div>
        
            <Slider
                name="panXSensitivity"
                bind:value={panXSensitivity}
                min={0.1}
                max={2}
                step={0.1}>
                X-axis sensitivity
            </Slider>

            <Slider
                name="panYSensitivity"
                bind:value={panYSensitivity}
                min={0.1}
                max={2}
                step={0.1}>
                Y-axis sensitivity
            </Slider>
        </div>
    </div>

    <div class="group" role="group" aria-labelledby="touchscreen">
        <div class="widthContainer">
            <h3 id="touchscreen" class="heading">Touchscreen</h3>
            
            <Slider
                name="pinchZoomSensitivity"
                bind:value={pinchZoomSensitivity}
                min={0.01}
                max={1}
                step={0.01}>
                Pinch zoom sensitivity
            </Slider>
        </div>
    </div>

    <div class="group" role="group" aria-labelledby="mouseTrackpad">
        <div class="widthContainer">
            <h3 id="mouseTrackpad" class="heading">Mouse/trackpad</h3>
            
            <Slider
                name="mouseZoomSensitivity"
                bind:value={mouseZoomSensitivity}
                min={0.1}
                max={2}
                step={0.1}>
                Zoom sensitivity
            </Slider>

            <Checkbox
                id="mouseZoomDirection"
                bind:value={mouseZoomDirection}>
                Invert zoom
            </Checkbox>

            <Slider
                name="mouseZoomLimit"
                bind:value={mouseZoomLimit}
                min={1}
                max={30}
                step={1}>
                Maximum zoom step
            </Slider>

            <Checkbox
                id="zoomWithCtrl"
                bind:value={zoomWithCtrl}>
                Hold CMD/CTRL to zoom
            </Checkbox>
        </div>
    </div>

    <div class="group" role="group" aria-labelledby="scrolling">
        <div class="widthContainer">
            <div class="headingWithButton">
                <h3 id="scrolling">Scrolling</h3>
                <LockInput bind:locked={lockScroll} id="lockScroll">
                    sync scroll for both axes
                </LockInput>
            </div>
            
            <Slider
                name="scrollXSensitivity"
                bind:value={scrollXSensitivity}
                min={0.1}
                max={2}
                step={0.1}>
                X-axis sensitivity
            </Slider>

            <Checkbox
                id="scrollXDirection"
                bind:value={scrollXDirection}>
                Invert X-axis
            </Checkbox>

            <Slider
                name="scrollYSensitivity"
                bind:value={scrollYSensitivity}
                min={0.1}
                max={2}
                step={0.1}>
                Y-axis sensitivity
            </Slider>

            <Checkbox
                id="scrollYDirection"
                bind:value={scrollYDirection}>
                Invert Y-axis
            </Checkbox>
        </div>
    </div>

    <div class="group">
        <div class="widthContainer">
            <button type="button" class="iconButton large">
                <Reset />
                Reset values
            </button>
            <button
                type="button"
                class="iconButton large"
                on:click={() => showControls = false}>
                <Cross />
                Close controls
            </button>
        </div>
    </div>
</form>



<style lang="scss">
    form {
        // internal variables
        --_form-maxWidth: unset;
        
        flex-shrink: 0;
        position: relative;
        width: 300px;
        height: 100vh;

        padding-bottom: calc(10px + env(safe-area-inset-bottom));
        border-left: solid 1px var(--PXL-clr-border);
        background-color: var(--PXL-clr-bg);

        overflow-y: auto;

        h2, h3 {
            color: var(--PXL-clr-1000);
            font-size: 1rem;
            font-weight: 700;
        }

        .group {
            padding-bottom: 10px;
            border-top: solid 1px var(--PXL-clr-border);
        }

        .widthContainer {
            max-width: var(--_form-maxWidth);
            margin: 0 auto;
        }

        .heading {
            padding: var(--PXL-controls-pad-vrt) var(--PXL-controls-pad-hrz);
        }

        .headingWithButton {
            display: flex;
            flex-flow: row wrap;
            align-items: stretch;
            justify-content: space-between;

            h2, h3 {
                padding: var(--PXL-controls-pad-vrt) 0 var(--PXL-controls-pad-vrt) var(--PXL-controls-pad-hrz);
            }
        }

        .large.iconButton {
            width: 100%;
            justify-content: flex-start;
            gap: 8px;
        }
    }

    /* === BREAKPOINTS ======================== */
    @media (max-width: 600px) {
        form {
            // internal variables 
            --_form-maxWidth: 400px;

            position: fixed;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            width: 100%;
            height: unset;
        }
    }
</style>