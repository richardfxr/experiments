<script lang="ts">
    /* === PROPS ============================== */
    export let width: number;
    export let height: number;
    export let id: string;
    export let patternSize: number;
    export let patternRadius: number;
    export let fill: string;
    export let period: number;
</script>



<svg
    {width}
    {height}
    style="--_period: {period}s;"
    xmlns="http://www.w3.org/2000/svg">
    <defs>
      <pattern
        {id}
        x="0"
        y="0"
        width={patternSize}
        height={patternSize}
        patternUnits="userSpaceOnUse">
        <circle
          cx={patternSize / 2}
          cy={patternSize / 2}
          r={patternRadius}
          {fill} />
      </pattern>
    </defs>
  
    <rect fill="url(#{id})" {width} {height} />
</svg>



<style lang="scss">
    svg {
        display: block;
        position: absolute;
        mix-blend-mode: multiply;

        animation: rotate var(--_period) linear infinite;
    }

    @keyframes rotate {
        from {
            transform: rotate(0deg);
        }
        to {
            transform: rotate(360deg);
        }
    }
</style>