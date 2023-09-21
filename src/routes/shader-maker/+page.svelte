<script lang="ts">
    /* === IMPORTS ============================ */
    import Canvas from "$lib/SHD-canvas.svelte";
</script>



<main>
    <Canvas />
    <div class="controls"></div>
</main>




<style lang="scss" global>
    main {
        display: flex;
        flex-flow: row nowrap;
        background-color: black;
    }

    #canvas {
        height: 100vh;
        width: 100vh;
        background-color: rebeccapurple;
    }

    // === MEDIA QUERIES ==========================
    @media (orientation: portrait) {
        main {
            display: block;
        }

        #canvas {
            height: 100vw;
            width: 100vw;
        }
    }
</style>