<script lang="ts">
    /* === IMPORTS ============================ */
    import { MeshBasicMaterial } from 'three';
    import Globe from 'globe.gl';
    import { onMount } from 'svelte';
    import { browser } from '$app/environment';
    import { goto } from '$app/navigation';
    import { UGNglobe, UGNcountryInfo, UGNaltOffset } from '../store/store.js';
    import type { Country } from '../store/store.js';    
    import countries from '$lib/globe-countries.json';
    import { Uganda } from '../routes/uganglobe/data.js';
    import Plus from '$lib/SVGs/UGN-plus.svelte';
    import Minus from '$lib/SVGs/UGN-minus.svelte';
    import UpIndicactor from '$lib/SVGs/UGN-upIndicactor.svelte';
    import EnterFullscreen from './SVGs/UGN-enterFullscreen.svelte';
    import ExitFullscreen from './SVGs/UGN-exitFullscreen.svelte';

    /* === PROPS ============================== */
    export let countryInfo: { [key: string]: {flag: string, lat: number, lng: number} };
    export let curCountries: Country[];
    export let globeHoverCountry: Country | null;
    export let listHoverCountry: Country | null;

    /* === REFS =============================== */
    let globeContainer: HTMLElement;
    let globeViz: HTMLElement;
    let scrollToTopObserver: HTMLElement;

    /* === VARIABLES ========================== */
    let curAlt = 0;
    let allowFullscreen = false;
    let isFullscreen = false;

    /* === REACTIVE DECLARATIONS ============== */
    $: if ($UGNglobe) $UGNglobe.arcsData(curCountries);
    $: setArcColors(listHoverCountry);

    /* === FUNCTIONS ========================== */
    function resizeGlobe() {
        // check that we are on browser and that globe and globeContainer exists
        if (!browser || !$UGNglobe || !globeContainer) return;

        // update globe width and height
        $UGNglobe
            .width(globeContainer.offsetWidth)
            .height(globeContainer.offsetHeight);
    };

    function getArcColor(country: Country, hoverCountry: Country | null) {
        if (hoverCountry === null || country.id === hoverCountry.id) return 'rgba(230, 30, 0, 1)';
        
        return 'rgba(230, 30, 0, 0.3)';
    };

    function setArcColors(hoverCountry: Country | null) {
        if (!$UGNglobe) return;
        
        $UGNglobe.arcColor((country: any) => getArcColor(country, hoverCountry));
    };

    function zoom(type: "in" | "out"): void {
        if (!$UGNglobe) return;

        let altChange = 0;
        type === "in" ? altChange = -0.3 : altChange = 0.3;

        $UGNglobe.pointOfView({ altitude: curAlt + altChange }, 200);
    }

    function checkFullscreen(): void {
        // @ts-ignore
        isFullscreen = document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement || document.msFullscreenElement;
    }

    function toggleFullscreen(): void {
        if (!allowFullscreen) return;

        // check if document is currently full screen
        if (isFullscreen) {
            // get supported exitFullScreen
            // @ts-ignore
            let cancelFullScreen = document.exitFullscreen || document.mozCancelFullScreen || document.webkitExitFullscreen || document.msExitFullscreen;
            cancelFullScreen.call(document);
            isFullscreen = false;
        } else {
            // get supported requestFullScreen
            // @ts-ignore
            let requestFullScreen = document.documentElement.requestFullscreen || document.documentElement.mozRequestFullScreen || document.documentElement.webkitRequestFullScreen || document.documentElement.msRequestFullscreen;
            requestFullScreen.call(document.documentElement);
            isFullscreen = true;
        }
    }
    
    /* === LIFECYCLE ========================== */
    onMount(() => {
        // initilize globe
        $UGNglobe = Globe()
            .width(globeContainer.offsetWidth)
            .height(globeContainer.offsetHeight)
            .backgroundColor('#ffffff')
            .globeMaterial(new MeshBasicMaterial({ color: '#f2f2f2' }))
            .showAtmosphere(false) 
            .onGlobeReady(() => console.log("ready"))
            .polygonsData(countries.features)
            .polygonCapColor(() => '#d1d1d1')
            .polygonSideColor(() => '#a3a3a3')
            .polygonStrokeColor(() => '#a3a3a3')

            .arcStartLat((country: any) => countryInfo[country.id].lat)
            .arcStartLng((country: any) => countryInfo[country.id].lng)
            .arcEndLat(() => Uganda.lat)
            .arcEndLng(() => Uganda.lng)
            .arcLabel((country: any) => {
                return `<p class="arcLabel">${$UGNcountryInfo[country.id].name} <span class="population">${Intl.NumberFormat().format(country.totalPopulation)}</span></p>`
            })
            .arcStroke(() => 0.5)
            .arcCurveResolution(32)
            .arcsTransitionDuration(0)
            .arcColor((country: any) => getArcColor(country, null))
            .onArcHover((country: any) => {
                globeHoverCountry = country;
                setArcColors(country);
            })
            .onArcClick((country: any) => goto(`/uganglobe/${country.id}`))
        (globeViz);

        // set zoom based on aspect ratio
        if (globeContainer.offsetWidth <= globeContainer.offsetHeight)
            $UGNaltOffset = 0.6;

        $UGNglobe.onZoom(pov => curAlt = pov.altitude);

        // create intersection observer
        const intersectionObserver = new IntersectionObserver(entries => {
            entries.forEach(entry => {
                globeContainer.classList.toggle("offScreen", entry.isIntersecting);
            })
        }, {rootMargin: "0px 0px -100% 0px"});
        
        intersectionObserver.observe(scrollToTopObserver);

        // create resize observer
        const resizeObserver = new ResizeObserver(() => resizeGlobe());
        resizeObserver.observe(globeContainer);

        // check if full screen is allowed then check if any element is fullscreened
        allowFullscreen = document.fullscreenEnabled;
        checkFullscreen();

        return () => {
            // unobserve observers
            intersectionObserver.unobserve(scrollToTopObserver);
            resizeObserver.unobserve(globeContainer);
        };
	});
</script>



<div
    class="globeContainer"
    tabindex="-1"
    bind:this={globeContainer}>
    <div id="globeViz" bind:this={globeViz}></div>
    <div class="controls">
        <button
            class="zoom"
            type="button"
            disabled={curAlt <= 0.5}
            on:click={() => zoom("in")}>
            <span class="visuallyHidden">zoom in</span>
            <Plus />
        </button>
        <button
            class="zoom"
            type="button"
            disabled={curAlt >= 4}
            on:click={() => zoom("out")}>
            <span class="visuallyHidden">zoom out</span>
            <Minus />
        </button>
    </div>

    <button
        class="fullscreen"
        type="button"
        on:click={toggleFullscreen}
        disabled={!allowFullscreen}>
        {#if isFullscreen}
            <span class="visuallyHidden">exit fullscreen</span>
            <ExitFullscreen />
        {:else}
            <span class="visuallyHidden">enter fullscreen</span>
            <EnterFullscreen />
        {/if}
    </button>

    <div class="scrollToTop-observer" bind:this={scrollToTopObserver}></div>
    <button
        class="scrollToTop"
        type="button"
        tabindex="-1"
        on:click={() => {
            globeContainer.focus();
            setTimeout(function () {
                window.scrollTo(0, 0);
            },2);
        }}>
        <span class="visuallyHidden">back to top</span>
        <UpIndicactor />
    </button>
</div>



<style lang="scss">
    :global {
        body {
            // internal variables
            --_scrollToTop-height: calc(2 * var(--_pad-xl) + 15px);
        }

        .arcLabel {
            display: flex;
            flex-flow: row wrap;
            align-items: center;
            justify-content: center;
            gap: var(--_pad-sm);

            color: var(--_clr-900);
            font-size: var(--_font-md);
            font-weight: 700;
            line-height: 1.1em;
            text-align: center;

            padding: var(--_pad-sm) var(--_pad-md);
            background-color: var(--_clr-0);
            border-radius: var(--_border-radius-md);

            .population {
                color: var(--_clr-0);
                font-size: var(--_font-sm);
                font-weight: 400;

                padding: 0 var(--_pad-sm);
                background-color: var(--_clr-900);
                border-radius: var(--_border-radius-sm);
            }
        }

        
    }

    .globeContainer {
        position: sticky;
        top: var(--_pad-border);
        width: 100%;
        height: calc(100vh - 2 * var(--_pad-border));

        margin: var(--_pad-border) 0 var(--_pad-border) var(--_pad-border);
        background-color: #ffffff;
        border-radius: var(--_border-radius-md);
        overflow: hidden;
    }

    .controls {
        display: flex;
        flex-flow: column nowrap;
        position: absolute;
        top: var(--_pad-md);
        left: var(--_pad-md);

        background-color: var(--_clr-100);
        border-radius: var(--_border-radius-sm);

        .zoom {
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--_clr-800);
            position: relative;

            padding: var(--_pad-xl) var(--_pad-xl);
            background-color: var(--_clr-100);
            border-radius: var(--_border-radius-sm);

            transition: color var(--_trans-fast),
                        background-color var(--_trans-fast);

            :global(.icon) {
                display: block;
                width: 15px;
            }

            &:hover, &:focus {
                color: var(--_clr-900);
                background-color: var(--_clr-150);
            }

            &:focus-visible {
                outline-offset: calc(-1 * var(--_focus-outline-width));
                outline: var(--_focus-outline);
                z-index: 50;
            }

            &:active {
                color: var(--_clr-1000);
                background-color: var(--_clr-300);
            }

            &:disabled {
                cursor: not-allowed;
                color: var(--_clr-400);
                background-color: var(--_clr-100);
            }
        }
    }

    .fullscreen {
        display: flex;
        align-items: center;
        justify-content: center;
        position: absolute;
        top: var(--_pad-md);
        right: var(--_pad-md);

        background-color: var(--_clr-100);
        border-radius: var(--_border-radius-sm);

        color: var(--_clr-800);
        background-color: var(--_clr-100);
        padding: var(--_pad-xl) var(--_pad-xl);
        border-radius: var(--_border-radius-sm);

        transition: color var(--_trans-fast),
                    background-color var(--_trans-fast);

        :global(.icon) {
            display: block;
            width: 15px;
        }

        &:hover, &:focus {
            color: var(--_clr-900);
            background-color: var(--_clr-150);
        }

        &:focus-visible {
            outline-offset: calc(-1 * var(--_focus-outline-width));
            outline: var(--_focus-outline);
            z-index: 50;
        }

        &:active {
            color: var(--_clr-1000);
            background-color: var(--_clr-300);
        }

        &:disabled {
            display: none;
        }
    }

    .scrollToTop-observer {
        display: none;
        position: absolute;
        right: 0;
        bottom: 0;
        left: 0;
        pointer-events: none;

        height: var(--_scrollToTop-height);
    }

    :global {
        .scrollToTop {
            display: none;
            position: absolute;
            right: 0;
            bottom: 0;
            left: 0;
            width: 100%;
            color: var(--_clr-700);

            padding: var(--_pad-xl);
            background-color: var(--_clr-0);

            transition: color var(--_trans-fast),
                        background-color var(--_trans-fast),
                        transform var(--_trans-fast);

            .icon {
                display: block;
                width: 15px;
            }
        }
    }
    

    @media (max-width: $UGNbp-tablet) and (orientation: portrait), (max-width: $UGNbp-mobile) {
        .globeContainer {
            // internal variables
            --_height: 120vw;

            position: sticky;
            top: calc(-1 * var(--_height) + var(--_scrollToTop-height));
            width: calc(100% - var(--_pad-border));
            height: var(--_height);

            margin:
                calc(var(--_pad-border) / 2)
                calc(var(--_pad-border) / 2)
                calc(-1 * var(--_scrollToTop-height))
                calc(var(--_pad-border) / 2);
            background-color: #ffffff;
            border-radius: var(--_border-radius-md);
            overflow: hidden;
        }

        .controls {
            flex-flow: row-reverse nowrap;
        }

        .scrollToTop-observer {
            display: block;
        }

        :global {
            .scrollToTop {
                display: flex;
                justify-content: center;
                transform: translateY(var(--_scrollToTop-height));
            }

            .offScreen .scrollToTop {
                transform: translateY(0px);
            }
        }
    }
</style>