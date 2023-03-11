<script lang="ts">
    /* === IMPORTS ============================ */
    import Globe from '$lib/UGN-globe.svelte';
    import { untypedCountryInfo, untypedPopulationData } from './data.js';
    import {
        UGNcountryInfo,
        UGNpopulationData,
        UGNcurTimeIndex,
        UGNcurCountries,
        UGNglobeHoverCountry,
        UGNlistHoverCountry
    } from '../../store/store.js';

    // assign data to stores
    $UGNcountryInfo = untypedCountryInfo;
    $UGNpopulationData = untypedPopulationData;
    $UGNcurTimeIndex = $UGNpopulationData.length - 1;
</script>



<svelte:head>
    <meta name="theme-color" content="##f2f2f2" />
</svelte:head>

<main>
    <Globe 
        countryInfo={$UGNcountryInfo}
        curCountries={$UGNcurCountries}
        bind:globeHoverCountry = {$UGNglobeHoverCountry}
        bind:listHoverCountry = {$UGNlistHoverCountry} />

    <div class="sidebar">
        <slot></slot>

        <footer>
            Early preview. Expect bugs.
        </footer>
    </div>
</main>



<style lang="scss">
    // imports
    @import url('https://fonts.googleapis.com/css2?family=Manrope:wght@200;300;400;500;600;700;800&family=Montserrat:wght@500&display=swap');

    :global {
        *, *::before, *::after {
            font-family: 'Manrope', sans-serif;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            // internal variables
            --_pad-border: 20px;
            --_pad-4xl: 30px;
            --_pad-2xl: 20px;
            --_pad-xl: 15px;
            --_pad-lg: 12px;
            --_pad-md: 10px;
            --_pad-sm: 6px;
            --_pad-xs: 4px;
            --_border-radius-md: 7px;
            --_border-radius-sm: 5px;

            --_font-2xl: 3rem;
            --_font-lg: 1.2rem;
            --_font-md: 1.1rem;
            --_font-sm: 1rem;
            --_trans-fast: 0.1s ease;
            --_trans-normal: 0.2s ease;

            --_clr-1000: #000000;
            --_clr-900: #303030;
            --_clr-800: #474747;
            --_clr-700: #666666;
            --_clr-600: #7a7a7a;
            --_clr-500: #8d8d8d;
            --_clr-400: #a8a8a8;
            --_clr-300: #bebebe;
            --_clr-200: #d1d1d1;
            --_clr-150: #dbdbdb;
            --_clr-100: #e5e5e5;
            --_clr-50: #f2f2f2;
            --_clr-0: #ffffff;
            
            --_clr-accent-700: #eb6200;
            
            background-color: var(--_clr-50);
            // prevent scrollbar from disappearing and shifting layout
            overflow-y: scroll;
        }
    }

    main {
        display: flex;
        flex-flow: row nowrap;
        position: relative;
        width: 100%;
    }

    .sidebar {
        flex-shrink: 0;
        display: flex;
        flex-flow: column nowrap;
        width: 380px;

        padding: var(--_pad-border);
        overflow: auto;
    }

    footer {
        color: var(--_clr-700);
        
        padding-top: var(--_pad-4xl);
    }

    @media (max-width: 800px) {
        .sidebar {
            width: 320px;
        }
    }

    @media (max-width: $UGNbp-tablet) and (orientation: portrait), (max-width: $UGNbp-mobile) {
        :global {
            body {
                // internal variables
                --_pad-border: 25px;
            }
        }

        main {
            flex-flow: column nowrap;
            align-items: center;
            justify-content: stretch;
        }

        .sidebar {
            flex-shrink: unset;
            width: 100%;
            max-width: 500px;

            padding: var(--_pad-border);
        }
    }

    @media (max-width: 350px) {
        :global {
            body {
                // internal variables
                --_pad-border: 15px;
            }
        }
    }
</style>