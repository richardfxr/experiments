<script lang="ts">
    /* === PROPS ============================== */
    export let shape: number; // bind

    /* === CONSTANTS ========================== */
    const shapes = [
        { value: 1, name: "circle" },
        { value: 2, name: "triangle" },
        { value: 3, name: "square" },
        { value: 4, name: "pentagon" },
    ];
</script>



<h2 class="label">shape</h2>

<div class="shapeRadios">
    {#each shapes as iShape}
        <label class="label">
            <input
                type="radio"
                name={iShape.name}
                value={iShape.value}
                bind:group={shape}
            />
            {iShape.name}
        </label>
    {/each}
</div>



<style lang="scss">
    h2 {
        margin-top: 12px;
    }

    .shapeRadios {
        display: flex;
        flex-flow: row wrap;
        justify-content: center;
        gap: 10px;

        label {
            cursor: pointer;
            padding: 12px 5px;
        }
    }
</style>