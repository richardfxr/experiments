<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import { page } from '$app/stores';
    import {
        UGNglobe,
        UGNcountryInfo,
        UGNpopulationData,
        UGNcurTimeIndex,
        UGNglobeHoverCountry,
        UGNlistHoverCountry,
        UGNcurCountries
    } from '../../../store/store';
    import { Uganda } from '../data.js';
    import DateSelector from '$lib/UGN-dateSelector.svelte';
    import Menu from '$lib/SVGs/UGN-menu.svelte';

    /* === CONSTANTS ========================== */
    const slug = $page.params.slug;
    const ageGroupNames = [
        "0-4",
        "5-11",
        "12-17",
        "18-59",
        "60+"
    ]

    // assign data to stores
    $UGNcurCountries = [{
        id: slug,
        totalPopulation: 0
    }];

    /* === VARIABLES ========================== */
    let femalePopulation = [0, 0, 0, 0, 0];
    let malePopulation = [0, 0, 0, 0, 0];
    
    $: {
        let countryExists = false;

        $UGNpopulationData[$UGNcurTimeIndex].countries.forEach(country => {
            if (country.id === slug) {
                countryExists = true;
                $UGNcurCountries[0].totalPopulation =
                    country.population[0].reduce((a, b) => a + b, 0) +
                    country.population[1].reduce((a, b) => a + b, 0);
                femalePopulation = country.population[0];
                malePopulation = country.population[1];
            };
        });

        if (!countryExists) {
            // reset all data to 0
            $UGNcurCountries[0].totalPopulation = 0;
            femalePopulation = [0, 0, 0, 0, 0];
            malePopulation = [0, 0, 0, 0, 0];
        }
    };

    /* === LIFECYCLE ========================== */
    onMount(() => {
        // aim camera slightly above mid point between selected country and Uganda
        if ($UGNglobe) $UGNglobe.pointOfView({
            lat: (Uganda.lat + $UGNcountryInfo[slug].lat) / 2 + 19,
            lng: (Uganda.lng + $UGNcountryInfo[slug].lng) / 2
        }, 700);
    });
</script>



<div class="flag">
    <img src={"../" + $UGNcountryInfo[slug].flag} alt={$UGNcountryInfo[slug].name + " flag"}>
</div>

<h1 class="totalPopulation">
    <span class="bigNumber">{Intl.NumberFormat().format($UGNcurCountries[0].totalPopulation)}</span>
    <span class="smallText">refugees from {$UGNcountryInfo[slug].name}</span>
</h1>

<a href="/uganglobe" class="back">
    <Menu />
    all countries
</a>

<DateSelector />

<h2 class="ageTitle">Females by age</h2>
<ul class="ageGroups" id="female">
    {#each femalePopulation as femaleAgePopulation, i}
        <li class="ageGroup">
            <p class="name">{ageGroupNames[i]}</p>
            {#if femaleAgePopulation > 0}
                <p class="population">{Intl.NumberFormat().format(femaleAgePopulation)}</p>
            {:else}
                <p class="population zero">-</p>
            {/if}
        </li>
    {/each}
    <li class="ageGroup">
        <p class="name">total</p>
        {#if femalePopulation.reduce((a, b) => a + b, 0) > 0}
            <p class="population">{Intl.NumberFormat().format(femalePopulation.reduce((a, b) => a + b, 0))}</p>
        {:else}
            <p class="population zero">-</p>
        {/if}
    </li>
</ul>

<h2 class="ageTitle">Males by age</h2>
<ul class="ageGroups" id="male">
    {#each malePopulation as maleAgePopulation, i}
        <li class="ageGroup">
            <p class="name">{ageGroupNames[i]}</p>
            {#if maleAgePopulation > 0}
                <p class="population">{Intl.NumberFormat().format(maleAgePopulation)}</p>
            {:else}
                <p class="population zero">-</p>
            {/if}
        </li>
    {/each}
    <li class="ageGroup">
        <p class="name">total</p>
        {#if malePopulation.reduce((a, b) => a + b, 0) > 0}
            <p class="population">{Intl.NumberFormat().format(malePopulation.reduce((a, b) => a + b, 0))}</p>
        {:else}
            <p class="population zero">-</p>
        {/if}
    </li>
</ul>



<style lang="scss">
    .back {
        display: flex;
        flex-flow: row nowrap;
        align-items: center;
        width: 100%;
        
        order: -1;
        color: var(--_clr-700);
        font-size: var(--_font-sm);
        font-weight: 600;

        background-color: var(--_clr-100);
        border-radius: var(--_border-radius-md);
        margin-bottom: var(--_pad-xl);

        transition: color var(--_trans-fast),
                    background-color var(--_trans-fast);

        :global(.icon) {
            display: block;
            width: calc(15px + var(--_pad-2xl) + var(--_pad-md));
            padding: var(--_pad-xl) var(--_pad-md) var(--_pad-xl) var(--_pad-2xl);
        }

        &:hover {
            color: var(--_clr-900);
            background-color: var(--_clr-150);
        }

        &:focus, &:active {
            color: var(--_clr-1000);
            background-color: var(--_clr-200);
        }
    }

    .flag {
        width: 100px;
        background-color: var(--_clr-100);
        border-radius: var(--_border-radius-md);
        margin-top: var(--_pad-4xl);

        overflow: hidden;
    }

    .totalPopulation {
        display: flex;
        flex-flow: column nowrap;

        padding-top: var(--_pad-md);
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

    .ageTitle {
        color: var(--_clr-800);
        font-size: var(--_font-sm);
        font-weight: 600;
    }

    .ageGroups {

        &#female {
            margin-bottom: var(--_pad-4xl);
        }
        
        .ageGroup {
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

            &:hover {
                color: var(--_clr-1000);
                border-color: var(--_clr-500);
            }

            .name {
                text-align: left;
                font-size: var(--_font-lg);
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