<script lang="ts">
    /* === IMPORTS ============================ */
    import { UGNpopulationData, UGNcurTimeIndex } from '../store/store';
    import LeftArrow from '$lib/SVGs/UGN-leftArrow.svelte';
    import RightArrow from '$lib/SVGs/UGN-rightArrow.svelte';

    /* === FUNCTIONS ========================== */
    function previousMonth() {
        if ($UGNcurTimeIndex <= 0) return;
        $UGNcurTimeIndex--;
    }

    function nextMonth() {
        if($UGNcurTimeIndex >= $UGNpopulationData.length - 1) return;

        $UGNcurTimeIndex++;
    }
</script>


<div class="dateSelector">
    <button
        class="dateButton"
        type="button"
        on:click={previousMonth}
        disabled={$UGNcurTimeIndex <= 0}>
        <LeftArrow />
        <span class="visuallyHidden">previous month</span>
    </button>

    <p>{$UGNpopulationData[$UGNcurTimeIndex].time}</p>

    <button
        class="dateButton"
        type="button"
        on:click={nextMonth}
        disabled={$UGNcurTimeIndex >= $UGNpopulationData.length - 1}>
        <RightArrow />
        <span class="visuallyHidden">previous month</span>
    </button>
</div>



<style lang="scss">
    .dateSelector {
        order: -1;
        display: flex;
        flex-flow: row nowrap;
        align-items: center;
        justify-content: space-between;

        background-color: var(--_clr-150);
        border-radius: var(--_border-radius-md);
        overflow: hidden;
    }

    .dateButton {
        color: var(--_clr-700);

        padding: var(--_pad-xl) var(--_pad-2xl);
        background-color: var(--_clr-150);
        border-radius: var(--_border-radius-md);

        transition: color var(--_trans-fast),
                    background-color var(--_trans-fast);

        :global(.icon) {
            display: block;
            width: 15px;
        }

        &:hover {
            color: var(--_clr-900);
            background-color: var(--_clr-200);
        }

        &:active {
            color: var(--_clr-1000);
            background-color: var(--_clr-300);
        }

        &:disabled {
            cursor: not-allowed;
            color: var(--_clr-400);
            background-color: var(--_clr-150);
        }
    }

    p {
        color: var(--_clr-900);
        font-size: var(--_font-md);
        font-weight: 500;
    }
</style>