<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import {
        UGNglobe,
        UGNcountryInfo,
        UGNpopulationData,
        UGNcurTimeIndex,
        UGNglobeHoverCountry,
        UGNlistHoverCountry,
        UGNcurCountries,
        UGNsexSelection,
        UGNageSelection
    } from '../../store/store';
    import { Uganda } from './data.js';
    import Checkboxes from '$lib/UGN-checkboxes.svelte';
    import Search from '$lib/SVGs/UGN-search.svelte';
    import DateSelector from '$lib/UGN-dateSelector.svelte';

    // assign data to stores
    $UGNlistHoverCountry = null;

    /* === REFS =============================== */
    let searchInput: HTMLElement;
    let countriesList: HTMLElement;

    /* === VARIABLES ========================== */
    let searchTerm = "";
    let curTotalPopulation = 0;

    /* === REACTIVE DECLARATIONS ============== */
    $: {
        $UGNcurCountries = [];
        curTotalPopulation = 0;

        let searchTermLC = searchTerm.toLowerCase();

        $UGNpopulationData[$UGNcurTimeIndex].countries.forEach(country => {
            let totalPopulation = 0;

            // loop through country people arrays to get total population
            $UGNsexSelection.forEach(sexIndex =>{
                $UGNageSelection.forEach(ageIndex => {
                    totalPopulation += country.population[sexIndex][ageIndex];
                })
            });

            if (
                totalPopulation > 0 && 
                (
                    searchTerm === "" ||
                    country.id.toLowerCase().includes(searchTermLC) ||
                    $UGNcountryInfo[country.id].name.toLowerCase().includes(searchTermLC) ||
                    $UGNcountryInfo[country.id].altName?.toLowerCase().includes(searchTermLC)
                )
            ) {
                $UGNcurCountries.push(
                    {
                        id: country.id,
                        totalPopulation: totalPopulation
                    }
                );
            }

            curTotalPopulation += totalPopulation;
        });
    }

    /* === LIFECYCLE ========================== */
    onMount(() => {
        // aim camera slightly above Uganda
        if ($UGNglobe) $UGNglobe.pointOfView({
            lat: Uganda.lat + 19,
            lng: Uganda.lng
        }, 700);
    });
</script>



<h1 class="totalPopulation">
    <span class="bigNumber">{Intl.NumberFormat().format(curTotalPopulation)}</span>
    <span class="smallText">refugees in Uganda</span>
</h1>

<form
    class="searchForm"
    on:submit|preventDefault={() => {
        searchInput.blur();
        countriesList.scrollIntoView({ behavior: "auto" });
    }}>
    <div class="searchBar">
        <Search />
        <input
            type="search"
            autocomplete="off"
            placeholder="Search countries"
            bind:this={searchInput}
            bind:value={searchTerm}>
    </div>
    
    <div class="filters">
        <Checkboxes
            label="sex"
            options={[
                {label: 'female', value: 0},
                {label: 'male', value: 1}
            ]}
            bind:selection={$UGNsexSelection} />

        <Checkboxes
            label="age"
            options={[
                {label: '0-4', value: 0},
                {label: '5-11', value: 1},
                {label: '12-17', value: 2},
                {label: '18-59', value: 3},
                {label: '60+', value: 4}
            ]}
            bind:selection={$UGNageSelection} />
    </div>
</form>

<DateSelector />

<h2 class="countriesTitle" bind:this={countriesList}>Countries of origin</h2>
<ul class="countries">
    {#each $UGNcurCountries as country}
        <li>
            <a
                href={'/uganglobe/' + country.id}
                class="country"
                class:hover={$UGNglobeHoverCountry === country}
                class:dim={$UGNglobeHoverCountry !== null && $UGNglobeHoverCountry !== country}
                on:pointerenter={() => $UGNlistHoverCountry = country}
                on:pointerleave={() => $UGNlistHoverCountry = null}>
                <img class="flag" src={$UGNcountryInfo[country.id].flag} alt={$UGNcountryInfo[country.id].name + " flag"}>
                <p class="name">{$UGNcountryInfo[country.id].name}</p>
                {#if country.totalPopulation > 0}
                    <p class="population">{Intl.NumberFormat().format(country.totalPopulation)}</p>
                {:else}
                    <p class="population zero">-</p>
                {/if}
            </a>
        </li>
    {/each}
    {#if $UGNcurCountries.length === 0}
        <li class="country">
            <img class="flag" src="flags/none.svg" alt="a placeholder flag">
            <p class="name">no results</p>
            <p class="population zero">-</p>
        </li>
    {/if}
</ul>



<style lang="scss">
    .searchForm {
        order: -1;
        background-color: var(--_clr-150);
        border-radius: var(--_border-radius-md);
        margin-bottom: var(--_pad-xl);
        overflow: hidden;

        .searchBar {
            display: flex;
            flex-flow: row nowrap;
            gap: var(--_pad-md);
            width: 100%;

            color: var(--_clr-700);
            font-size: var(--_font-md);
            font-weight: 500;

            background-color: var(--_clr-100);
            border-radius: var(--_border-radius-md);

            transition: color 0.1s ease,
                        background-color 0.1s ease;

            &:hover {
                color: var(--_clr-900);
            }
            
            &:focus-within {
                color: var(--_clr-1000);
            }

            :global(.icon) {
                min-width: 18px;
                width: 18px;
                margin-left: var(--_pad-2xl);
            }

            input {
                padding: var(--_pad-md) var(--_pad-2xl) var(--_pad-md) 0;

                &::-webkit-search-cancel-button {
                    -webkit-appearance: none;
                }
            }
        }

        .filters {
            display: flex;
            flex-flow: column nowrap;
            gap: var(--_pad-md);
            padding: var(--_pad-md) var(--_pad-2xl) var(--_pad-2xl) var(--_pad-2xl);
        }
    }

    .totalPopulation {
        display: flex;
        flex-flow: column nowrap;

        padding-top: var(--_pad-4xl);
        padding-bottom: var(--_pad-4xl);

        span {
            display: block;
        }

        .bigNumber {
            color: var(--_clr-900);
            font-family: 'Montserrat', sans-serif;
            font-size: var(--_font-2xl);
            font-weight: 700;
            line-height: 1em;

            word-break: break-all;
        }

        .smallText {
            color: var(--_clr-700);
            font-size: var(--_font-sm);
            font-weight: 500;
            line-height: 1.2em;

            padding-top: var(--_pad-sm);
        }
    }

    .countriesTitle {
        color: var(--_clr-800);
        font-size: var(--_font-sm);
        font-weight: 600;
    }

    .countries {
        .country {
            display: flex;
            flex-flow: row nowrap;
            align-items: center;
            gap: var(--_pad-md);
            width: 100%;

            color: var(--_clr-800);

            padding: var(--_pad-lg) 0;
            border-bottom: solid 1px var(--_clr-200);

            transition: color var(--_trans-fast),
                        opacity var(--_trans-normal),
                        border-color var(--_trans-fast);

            &:hover, &.hover {
                color: var(--_clr-1000);
                border-color: var(--_clr-500);
            }

            &.dim {
                opacity: 0.6;
            }

            .flag {
                width: 1.8rem;
            }

            .name {
                text-align: left;
                font-size: var(--_font-md);
                font-weight: 700;
                line-height: 1.1em;
            }

            .population {
                color: var(--_clr-0);
                font-size: var(--_font-sm);
                font-weight: 400;

                padding: 0 var(--_pad-sm);
                background-color: var(--_clr-900);
                border-radius: var(--_border-radius-sm);
                margin-left: auto;

                &.zero {
                    color: inherit;
                    background-color: transparent;
                }
            }
        }
    }
</style>