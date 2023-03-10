<script lang="ts">
    /* === IMPORTS ============================ */
    import { MeshBasicMaterial } from 'three';
    import Globe from 'globe.gl';
    import { onMount } from 'svelte';
    import { browser } from '$app/environment';
    import { goto } from '$app/navigation';
    import { UGNglobe } from '../store/store';
    import { UGNcountryInfo, UGNaltOffset } from '../store/store.js';
    import type { Country } from '../store/store.js';    
    import countries from '$lib/globe-countries.json';
    import { Uganda } from '../routes/uganglobe/data.js';

    /* === PROPS ============================== */
    export let countryInfo: { [key: string]: {flag: string, lat: number, lng: number} };
    export let curCountries: Country[];
    export let globeHoverCountry: Country | null;
    export let listHoverCountry: Country | null;

    /* === REFS =============================== */
    let globeContainer: HTMLElement;
    let globeViz: HTMLElement;

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
        if (hoverCountry === null || country.id === hoverCountry.id) return 'rgba(235, 98, 0, 1)';
        
        return 'rgba(235, 98, 0, 0.3)';
    };

    function setArcColors(hoverCountry: Country | null) {
        if (!$UGNglobe) return;
        
        $UGNglobe.arcColor((country: any) => getArcColor(country, hoverCountry));
    };
    
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
	});
</script>



<svelte:window on:resize={resizeGlobe}></svelte:window>

<div
    class="globeContainer"
    bind:this={globeContainer}>
    <div id="globeViz" bind:this={globeViz}></div>
</div>



<style lang="scss">
    :global {
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

    @media (max-width: $UGNbp-tablet) and (orientation: portrait), (max-width: $UGNbp-mobile) {
        .globeContainer {
            position: relative;
            top: unset;
            width: calc(100% - var(--_pad-border));
            height: 120vw;

            margin: calc(var(--_pad-border) / 2);
            background-color: #ffffff;
            border-radius: var(--_border-radius-md);
            overflow: hidden;
        }
    }
</style>