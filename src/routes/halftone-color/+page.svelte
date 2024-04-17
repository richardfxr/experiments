<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from "svelte";
    import Pattern from "$lib/HLF-pattern.svelte";

    /* === CONSTANTS ========================== */
    const basePeriod = 15;
    const wheelSensitivity = -0.001;

    /* === BINDINGS =========================== */
    let container: HTMLDivElement;

    /* === VARIABLES ========================== */
    let width = 0;
    let height = 0;
    let diagonal = 0;
    let pointerX = 0.5;
    let pointerY = 0.5;
    let wheelX = 0.5;
    let wheelY = 0.5;

    /* === FUNCTIONS ========================== */
    function clamp(input: number, min: number, max: number): number {
        return Math.min(Math.max(input, min), max);
    }

    function handleResize() {
        width = container.clientWidth;
        height = container.clientHeight;
        diagonal = Math.sqrt(width ** 2 + height ** 2);
    }

    function handlePointer(event: PointerEvent) {
        pointerX = event.clientX / width;
        pointerY = event.clientY / height;
    }

    function handleWheel(event: WheelEvent) {
        event.preventDefault();

        if (event.ctrlKey) {
            wheelX = clamp(
                wheelX + event.deltaY * wheelSensitivity,
                0,
                1
            );
            wheelY = clamp(
                wheelY + event.deltaX * wheelSensitivity,
                0,
                1
            );
        } else {
            wheelX = clamp(
                wheelX + event.deltaX * wheelSensitivity,
                0,
                1
            );
            wheelY = clamp(
                wheelY + event.deltaY * wheelSensitivity,
                0,
                1
            );
        }
    }

    /* === LIFECYCLE ========================== */
    onMount(() => {
        handleResize();
    });
</script>



<svelte:window on:resize={handleResize}/>

<div
    class="container"
    bind:this={container}
    on:pointerdown={handlePointer}
    on:pointermove={handlePointer}
    on:wheel={handleWheel}>
    <Pattern
        width={diagonal}
        height={diagonal}
        id="cyan"
        patternSize={10}
        patternRadius={pointerX * 4}
        fill="#00FFFF"
        period={basePeriod}
    />
    <Pattern
        width={diagonal}
        height={diagonal}
        id="magenta"
        patternSize={10}
        patternRadius={pointerY * 4}
        fill="#FF00FF"
        period={2 * basePeriod}
    />
    <Pattern
        width={diagonal}
        height={diagonal}
        id="yellow"
        patternSize={10}
        patternRadius={wheelX * 4}
        fill="#FFFF00"
        period={3 * basePeriod}
    />
    <Pattern
        width={diagonal}
        height={diagonal}
        id="black"
        patternSize={10}
        patternRadius={wheelY * 4}
        fill="#000000"
        period={4 * basePeriod}
    />
</div>



<style lang="scss">
    .container {
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
        width: 100%;
        height: 100vh;
        overflow: hidden;
    }
</style>