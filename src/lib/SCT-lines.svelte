<script lang="ts">
    /* === PROPS ============================== */
    export let numPoints: number;
    export let origin: { x: number, y: number};
    export let points: { x: number, y: number }[];
    export let animationCompleted: boolean;
</script>



<svg
    id="lines"
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 100 100"
    preserveAspectRatio="none">
    {#each {length: points.length} as _, i (i)}
        <line
            class:shown={animationCompleted && i < numPoints}
            x1={origin.x}
            y1={origin.y}
            x2={points[i].x}
            y2={points[i].y}
            vector-effect="non-scaling-stroke" />
    {/each}
</svg>



<style lang="scss">
    #lines {
        width: 100%;
        height: 100%;

        line {
            stroke: var(--SCT-clr-line);
            opacity: 0;

            transition: opacity 0s linear;

            &.shown {
                opacity: 1;
                transition: opacity var(--SCT-trans-normal) var(--SCT-trans-cubic-1);
            }
        }
    }
</style>