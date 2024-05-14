<script lang="ts">
    /* === IMPORTS ============================ */
    import { createEventDispatcher } from 'svelte';
    import {
        type Rule,
        neighborhoodSideLength,
        neighborhoodMidpoint,
        neighborhoodCenterIndex
    } from "$lib/MNCA-controls.svelte";

    /* === PROPS ============================== */
    export let rules: Rule[]; // bind
    export let size: number;
    export let index: number;
    export let isOverride = false;

    /* === CONSTANTS ========================== */
    const dispatch = createEventDispatcher();
    const numDigits = 3; // length of each number with padding

    /* === HANDLERS =========================== */
    function handleRuleChange(cellIndex: number) {
        // @ts-ignore, update rules array
        rules[cellIndex] = (rules[cellIndex] + 1) % 3;

        // dispatch event
        dispatch("ruleChange", {
            neighborhoodIndex: index,
            cellIndex,
            isOverride
        });
    }
</script>



<ul class="rules">
    {#each {length: size + 1} as _, i}
        <li>
            <button
                class="rule{rules[i]}"
                type="button"
                on:click={() => handleRuleChange(i)}>
                {String(i).padStart(3, '0')}
                <span class="visuallyHidden">
                    {i === 1 ? 'cell': 'cells'}: {rules[i] === 0 ? 'death' : rules[i] === 1 ? "birth" : "no change"}
                </span>
            </button>
        </li>
    {/each}
</ul>



<style lang="scss">
    // internal variables
    $_border-thick-width: 1.5px;
    $_border-thick: solid $_border-thick-width var(--MNCA-clr-1000);
    $_border-thin-width: 1px;
    $_border-thin: solid $_border-thin-width var(--MNCA-clr-600);
    $_trans-fast: 0.2s ease-in-out;

    .rules {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(5.5ch, 1fr));
        position: relative;

        font-weight: 700;
        // border compensation
        padding:
            $_border-thick-width
            calc($_border-thick-width - $_border-thin-width)
            calc($_border-thick-width - $_border-thin-width)
            $_border-thick-width;

        &::before {
            // outer border
            content: "";
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            border: $_border-thick;
            pointer-events: none;
        }

        li {
            button {
                width: 100%;

                color: var(--MNCA-clr-1000);
                padding: 4px 0;
                border-right: $_border-thin;
                border-bottom: $_border-thin;

                -webkit-user-select: none;
                -moz-user-select: none;
                user-select: none;

                &:hover, &:focus {
                    background-color: var(--MNCA-clr-100);
                }

                &:focus-visible {
                    outline: 2px solid var(--MNCA-clr-1000);
                    outline-offset: -5px;
                }

                &.rule0 {
                    background-color: var(--MNCA-clr-red);
                    color: var(--MNCA-clr-bg);

                    &:hover, &:focus {
                        background-color: var(--MNCA-clr-red-hover);
                    }

                    &:focus-visible {
                        outline-color: var(--MNCA-clr-bg);
                    }
                }

                &.rule1 {
                    background-color: var(--MNCA-clr-teal);
                    color: var(--MNCA-clr-bg);

                    &:hover, &:focus {
                        background-color: var(--MNCA-clr-teal-hover);
                    }

                    &:focus-visible {
                        outline-color: var(--MNCA-clr-bg);
                    }
                }
            }
        }
    }
</style>