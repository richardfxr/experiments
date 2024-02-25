<script lang="ts">
    /* === PROPS ============================== */
    export let src: string;
    export let alt: string;
</script>



<picture>
    <source srcset="{src}.avif" type="image/avif" />
    <source srcset="{src}.webp" type="image/webp" />
    <img src="{src}.jpg" {alt} />
</picture>