<script lang="ts">
    /* === IMPORTS ============================ */
    // Svelte
    import { onMount } from 'svelte';
    // variables
    import {
        timeSclaeMax,
        timeScaleMin,
        zoomMax,
        zoomMin,
        offsetMax,
        offsetMin,
        timeScale,
        zoom,
        offsetR,
        offsetG,
        offsetB,
        shape
    } from "$lib/SHD-canvas.svelte";
    // components
    import Canvas from "$lib/SHD-canvas.svelte";
    import Slider from "$lib/SHD-slider.svelte";
    import ShapeRadios from "$lib/SHD-shapeRadios.svelte";
    import Cross from "$lib/SVGs/SHD-cross.svelte";
    import Reset from "$lib/SVGs/SHD-reset.svelte";
    import Circle from "$lib/SVGs/SHD-circleIcon.svelte";
    import Triangle from "$lib/SVGs/SHD-triangleIcon.svelte";
    import Square from "$lib/SVGs/SHD-squareIcon.svelte";
    import Pentagon from "$lib/SVGs/SHD-pentagonIcon.svelte";

    /* === VARIABLES ========================== */
    let hideControls = false;
    let controlsAreHidden = false;

    /* === BINDINGS =========================== */
    let controls: HTMLDialogElement;

    /* === FUNCTIONS ========================== */
    function closeControlsDialog() {
        if (controlsAreHidden) return;

        hideControls = true;
        controlsAreHidden = true;

        // add a one-time transition end event listener
        controls.addEventListener("transitionend", () => {
            hideControls = false;
            controls.close();
        }, { once: true });
    }

    /* === LIFE CYCLES ======================== */
    onMount(() => {
        // open dialog
        controlsAreHidden = false;
        controls.showModal();
	});
</script>



<svelte:head>
    <title>Hypnosis</title>
    <meta
        name="description"
        content="A customizable hypnotic animation."
    />
    <link rel="icon" href="SHD-favicon.png" />
    <meta name="theme-color" content="#000000" />
    <!-- open graph image -->
    <meta property="og:image" content="/SHD-og-image-1.jpg" />
    <meta property="og:image:type" content="image/jpeg" />
    <meta property="og:image:width" content="1200" />
    <meta property="og:image:height" content="630" />
    <meta property="og:image:alt" content="Concentric circles emerging from the center, changing color as they move further away." />
</svelte:head>

<main>
    <h1 class="visuallyHidden">Customizable hypnotic animation.</h1>
    <Canvas />
    <button
        class="controlsButton"
        class:hidden={!controlsAreHidden}
        on:click={() => {
            controlsAreHidden = false;
            controls.showModal();
        }}>
        <span class="visuallyHidden">open controls</span>
        <div class="sliderPreviews" role="presentation">
            <div
                style="
                    --_clr: #fff174;
                    --_percent: {($timeScale / 6) * 100}%;
                ">
            </div>
            <div
                style="
                    --_clr: #f8a45f;
                    --_percent: {($zoom / 1.2) * 100}%;
                ">
            </div>
            <div
                style="
                    --_clr: #ff8282;
                    --_percent: {$offsetR * 100}%;
                ">
            </div>
            <div
                style="
                    --_clr: #48f348;
                    --_percent: {$offsetG * 100}%;
                ">
            </div>
            <div
                style="
                    --_clr: #8585ff;
                    --_percent: {$offsetB * 100}%;
                ">
            </div>
        </div>
        {#if $shape === 1}
            <Circle />
        {:else if $shape === 2}
            <Triangle />
        {:else if $shape === 3}
            <Square />
        {:else}
            <Pentagon />
        {/if}
    </button>
    <dialog
        class="controls"
        class:hidden={hideControls}
        bind:this={controls}
        on:click={event => {if (event.target === controls) closeControlsDialog();}}
        on:keyup={event => {if (event.key === "Escape") closeControlsDialog();}}>
        <form
            method="dialog"
            aria-labelledby="controlsLabel"
            on:keydown={event => {
                if (event.key === "Escape") {
                    event.preventDefault();
                    closeControlsDialog();
                }
            }}>
            <div class="header">
                <h2 class="label" id="controlsLabel">controls</h2>
                <button
                    class="button"
                    on:click|preventDefault={closeControlsDialog}>
                    <span class="visuallyHidden">close</span>
                    <Cross />
                </button>
            </div>
            
            <Slider
                bind:value={$timeScale}
                id="timeScale"
                min={timeScaleMin}
                max={timeSclaeMax}
                step={0.1}
                thumbColor="#fff6a3"
                shadowColor="#e8d100">
                speed
            </Slider>
            <Slider
                bind:value={$zoom}
                id="zoom"
                min={zoomMin}
                max={zoomMax}
                step={0.001}
                thumbColor="#ffd1ab"
                shadowColor="#ff7300">
                zoom
            </Slider>
            <Slider
                bind:value={$offsetR}
                id="offsetR"
                min={offsetMin}
                max={offsetMax}
                step={0.001}
                thumbColor="#ffabab"
                shadowColor="#ff0000">
                red offset
            </Slider>
            <Slider
                bind:value={$offsetG}
                id="offsetG"
                min={offsetMin}
                max={offsetMax}
                step={0.001}
                thumbColor="#96ff96"
                shadowColor="#00ba00">
                green offset
            </Slider>
            <Slider
                bind:value={$offsetB}
                id="offsetB"
                min={offsetMin}
                max={offsetMax}
                step={0.001}
                thumbColor="#c9c9ff"
                shadowColor="#3b3bff">
                blue offset
            </Slider>
            <ShapeRadios bind:shape={$shape} />
            <div class="actions">
                <button
                    type="button"
                    class="button label"
                    on:click={() => {
                        // reset all values to default
                        timeScale.set(2);
                        zoom.set(0.5);
                        offsetR.set(0.498);
                        offsetG.set(0.268);
                        offsetB.set(0.068);
                        shape.set(1);
                    }}>
                    <Reset />
                    <span>reset</span>
                </button>
                <button
                    class="button label"
                    on:click|preventDefault={closeControlsDialog}>
                    <Cross />
                    <span>close</span>
                </button>
            </div>
        </form>
    </dialog>
</main>




<style lang="scss">
    $_sliderPreview-width: 2px;
    $_sliderPreview-height: 7px;
    $_controls-maxWidth: 400px;
    $_controls-bg: rgba(0, 0, 0, 0.9);
    $_controls-borderRadius: 7px;
    $_controls-pad: 15px;
    $_controls-duration: 0.35s;
    $_controls-easing: cubic-bezier(0.6, 0, 0.4, 1);

    :root {
        // variables
        --SHD-border-width: 1px;
        --SHD-border-thick-width: 2px;
        --SHD-border-clr: rgba(255, 255, 255, 0.25);
        --SHD-trans-fast: 0.15s;
        --SHD-trans-normal: 0.2s;
        --SHD-trans-slow: 0.25s;
        --SHD-slider-height: 50px;
    }

    *, *::before, *::after {
        font-family: 'General Sans', sans-serif;
    }

    body {
        background-color: black;
    }
    
    main {
        position: relative;
    }

    .controlsButton {
        display: flex;
        flex-flow: column nowrap;
        align-items: center;
        gap: 10px;
        position: fixed;
        right: 0;
        bottom: 0;
        width: 44px;

        padding-bottom: 10px;
        margin: 15px;
        background-color: $_controls-bg;
        border-radius: 4px;

        opacity: 1;
        transform-origin: bottom right;
        transition: transform $_controls-duration $_controls-easing,
                    opacity $_controls-duration $_controls-easing;

        overflow: hidden;

        &::before {
            content: "";
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            z-index: -1;

            background-color: white;

            opacity: 0;
            transition: opacity 0.15s ease;
        }

        &:hover, &:focus, &:active {
            .sliderPreviews div, :global(.icon) {
                opacity: 1;
            }
        }

        &:focus-visible {
            &::before {
                opacity: 1;
            }

            .sliderPreviews {
                border-color: black;

                div::before {
                    background-color: black;
                }
            } 

            :global {
                .icon .stroke {
                    stroke: black;
                }
            }
        }

        &.hidden {
            transform: scale(4);
            opacity: 0;
        }

        .sliderPreviews {
            width: 100%;
            border-bottom: solid var(--SHD-border-width) var(--SHD-border-clr);

            transition: border-color 0.15s ease;

            div {
                position: relative;
                height: $_sliderPreview-height;
                width: 100%;

                opacity: 0.9;
                transition: background-color 0.15s ease,
                            opacity 0.15s ease;

                &::before {
                    content: "";
                    position: absolute;
                    top: 0;
                    bottom: 0;
                    left: calc(var(--_percent) - ($_sliderPreview-width * 0.5));
                    width: $_sliderPreview-width;
                    background-color: var(--_clr);

                    transition: background-color 0.15s ease;
                }
            }
        }

        :global {
            .icon {
                display: block;
                width: 20px;

                opacity: 0.9;
                transition: background-color 0.15s ease,
                            opacity 0.15s ease;

                .stroke {
                    fill: none;
                    stroke: white;
                    stroke-width: 1px;
                    stroke-linecap: round;
                    stroke-linejoin: round;
                    transition: stroke 0.15s ease;
                }
            }
        }
    }

    .controls {
        // reset dialog default styling
        inset: unset;
        background-color: transparent;
        border: none;
        max-width: 100%;

        justify-content: flex-end;
        position: fixed;
        top: 0;
        right: 0;
        bottom: 0;
        max-height: 100%;
        width: min($_controls-maxWidth, calc(100% - 2 * $_controls-pad));
        
        padding: $_controls-pad 0 0 0;
        margin: auto $_controls-pad $_controls-pad $_controls-pad;

        transform-origin: bottom right;
        transition: transform $_controls-duration $_controls-easing,
                    opacity $_controls-duration $_controls-easing;

        &[open] {
            animation: $_controls-duration $_controls-easing 1 showControls;
        }

        &::backdrop {
            opacity: 0;
        }

        &.hidden {
            transform: scale(0.1);
            opacity: 0;
        }
        
        form {
            max-height: calc(100vh - 30px);

            background-color: $_controls-bg;
            border-radius: $_controls-borderRadius;
            
            overflow: auto;

            .header {
                display: flex;
                flex-flow: row wrap;
                align-items: center;
                justify-content: space-between;
                border-bottom: solid var(--SHD-border-width) var(--SHD-border-clr);

                h2 {
                    font-weight: 600;
                    padding-left: $_controls-pad;
                }
            }

            .actions {
                display: flex;
                flex-flow: row wrap;
                align-items: center;
                justify-content: stretch;

                .button {
                    flex-grow: 1;
                    flex-flow: row nowrap;
                    justify-content: center;
                    gap: 10px;
                }
            }

            .button {
                display: flex;
                align-items: center;
                min-height: $input-minSize;

                color: white;
                padding: 10px $_controls-pad;

                opacity: 0.8;

                &:hover, &:focus {
                    opacity: 0.9;
                }

                &:active, &:focus-visible {
                    opacity: 1;
                }

                &:focus-visible {
                    color: black;
                    background-color: white;
                }
            }
        }
    }

    .label {
        color: white;
        font-size: 1rem;
        font-weight: 400;
        text-align: center;
    }

    @media (max-width: calc($_controls-maxWidth + $_controls-pad)) {
        .controls {
            left: 0;
        }
    }

    @keyframes showControls {
        from {
            transform: scale(0.1);
            opacity: 0;
        }

        to {
            transform: scale(1);
            opacity: 1;
        }
    }
</style>