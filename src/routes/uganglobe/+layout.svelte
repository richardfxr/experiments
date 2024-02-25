<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
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
    import RightIndicator from '$lib/SVGs/UGN-rightIndicator.svelte';
    import DownIndicator from '$lib/SVGs/UGN-downIndicator.svelte';

    // assign data to stores
    $UGNcountryInfo = untypedCountryInfo;
    $UGNpopulationData = untypedPopulationData;
    $UGNcurTimeIndex = $UGNpopulationData.length - 1;

    /* === REFS =============================== */
    let main: HTMLElement;
    let sideBar: HTMLElement;    

    /* === LIFECYCLE ========================== */
    onMount(() => {
        // create observer
        const observer = new IntersectionObserver(entries => {
            entries.forEach(entry => {
                main.classList.toggle("halfWay", entry.isIntersecting);
            })
        }, {rootMargin: "0px 0px -50% 0px"});
        
        observer.observe(sideBar);
    });
</script>



<svelte:head>
    <meta name="theme-color" content="##f2f2f2" />
</svelte:head>

<main bind:this={main}>
    <button
        class="skip"
        type="button"
        on:click={() => {
            sideBar.scrollIntoView();
            sideBar.focus();
        }}>
        <span class="visuallyHidden">skip three dimensional globe</span>
        <RightIndicator />
        <DownIndicator />
    </button>

    <Globe 
        countryInfo={$UGNcountryInfo}
        curCountries={$UGNcurCountries}
        bind:globeHoverCountry = {$UGNglobeHoverCountry}
        bind:listHoverCountry = {$UGNlistHoverCountry} />

    <div
        class="sidebar"
        tabindex="-1"
        bind:this={sideBar}>
        
        <slot></slot>

        <footer>
            <p>Data provided by the <a href="https://data.unhcr.org/en/country/uga" target="_blank" rel="noreferrer">UNHCR Uganda Comprehensive Refugee Response Portal</a>.</p>
            <p>Designed and developed by <a href="https://www.richardfxr.com/" target="_blank" rel="noreferrer author">Richard Fu</a>. <a href="https://github.com/richardfxr/misc" target="_blank" rel="noreferrer">Source code available on GitHub</a>.</p>
            <p><a href="https://www.khronos.org/webgl/" target="_blank" rel="noreferrer">WebGL</a> globe created with <a href="https://globe.gl/" target="_blank" rel="noreferrer">globe.gl</a>.</p>
            <p class="version">v1.0.0.beta1</p>
        </footer>
    </div>
</main>



<style lang="scss">
    // imports
    @import url('https://fonts.googleapis.com/css2?family=Manrope:wght@200;300;400;500;600;700;800&family=Montserrat:wght@500&display=swap');

    :global {
        html {
            scroll-behavior: smooth;
        }

        body {
            // internal variables
            --_pad-border: 20px;
            --_pad-4xl: 35px;
            --_pad-2xl: 20px;
            --_pad-xl: 15px;
            --_pad-lg: 12px;
            --_pad-md: 10px;
            --_pad-sm: 6px;
            --_pad-xs: 4px;
            --_border-radius-md: 7px;
            --_border-radius-sm: 5px;
            --_focus-outline-width: 3px;
            --_focus-outline: solid var(--_focus-outline-width) var(--_clr-accent-700);

            --_font-2xl: 3rem;
            --_font-lg: 1.2rem;
            --_font-md: 1.1rem;
            --_font-sm: 1rem;
            --_trans-fast: 0.1s ease;
            --_trans-normal: 0.2s ease;

            --_clr-1000: #000000;
            --_clr-950: #222222;
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
            
            font-family: 'Manrope', sans-serif;
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

    :global {
        .skip {
            position: fixed;
            top: calc(var(--_pad-border) + var(--_pad-md));
            left: calc(var(--_pad-border) + var(--_pad-md));
            z-index: 100;
            color: var(--_clr-150);

            padding: var(--_pad-xl) var(--_pad-xl);
            background-color: var(--_clr-900);
            border-radius: var(--_border-radius-sm);
            transform: translateY(calc(-1 * (var(--_pad-border) + var(--_pad-md) + 2 * var(--_pad-xl) + 15px)));

            transition: color var(--_trans-fast),
                        background-color var(--_trans-fast),
                        transform var(--_trans-fast);

            .icon {
                display: block;
                width: 15px;
            }

            #downIndicator {
                display: none;
            }

            &:hover, &:focus {
                transform: translateY(0px);
                color: var(--_clr-100);
                background-color: var(--_clr-950);
            }

            &:focus-visible {
                color: var(--_clr-0);
                background-color: var(--_clr-accent-700);
            }

            &:active {
                transform: translateY(0px);
                color: var(--_clr-0);
                background-color: var(--_clr-1000);
            }
        }
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
        display: flex;
        flex-flow: column nowrap;
        align-items: flex-start;
        gap: var(--_pad-lg);
        color: var(--_clr-700);
        
        padding-top: var(--_pad-4xl);

        a {
            text-decoration: underline;

            transition: color var(--_trans-fast);

            &:hover, &:focus {
                color: var(--_clr-900);
            }

            &:focus-visible {
                outline: var(--_focus-outline);
            }

            &:active {
                color: var(--_clr-1000);
            }
        }

        .version {
            padding: var(--_pad-xs) var(--_pad-md);
            border: solid 1px var(--_clr-300);
            border-radius: var(--_border-radius-sm);
        }
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

            padding-bottom: env(safe-area-inset-bottom);
        }

        :global {
            .skip {
                position: fixed;
                top: unset;
                left: unset;
                bottom: calc(var(--_pad-xl) + env(safe-area-inset-bottom));
                z-index: 100;
                color: var(--_clr-150);

                padding: var(--_pad-xl) var(--_pad-xl);
                background-color: var(--_clr-900);
                border-radius: var(--_border-radius-sm);
                transform: translateY(0px);

                transition: color var(--_trans-fast),
                            background-color var(--_trans-fast),
                            transform var(--_trans-fast);

                #rightIndicator {
                    display: none;
                }

                #downIndicator {
                    display: block;
                }
            }

            .halfWay .skip{
                transform: translateY(calc(var(--_pad-xl) + 2 * var(--_pad-xl) + 15px + env(safe-area-inset-bottom)));
            }
        }

        .sidebar {
            flex-shrink: unset;
            width: 100%;
            max-width: 500px;

            padding:
                calc(var(--_pad-border) + 2 * var(--_pad-xl) + 15px)
                var(--_pad-border)
                var(--_pad-border)
                var(--_pad-border);
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