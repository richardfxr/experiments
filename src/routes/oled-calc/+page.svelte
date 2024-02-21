<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;
    let files: FileList;

    /* === VARIABLES =========================== */
    let calculated = false;
    let totalPower = 0;
    let totalPixels = 0;
    let context: CanvasRenderingContext2D | null = null;

    /* === FUNCTIONS ========================== */
    function pRed(value: number): number {
        if (value <= 0) {
            return 0;
        } else if (value <= 63) {
            return Math.round(value * 267.254);
        } else if (value <= 127) {
            return 16837 + Math.round((value - 63) * 39.953);
        } else if (value <= 191) {
            return 19394 + Math.round((value - 127) * 119.641);
        } else {
            return 27051 + ((value - 191) * 247.5);
        }
    }

    function pGreen(value: number): number {
        if (value <= 0) {
            return 0;
        } else if (value <= 63) {
            return Math.round(value * 131.349);
        } else if (value <= 127) {
            return 8275 + Math.round((value - 63) * 10.891);
        } else if (value <= 191) {
            return 8972 + Math.round((value - 127) * 100.234);
        } else {
            return 15387 + Math.round((value - 191) * 345.672);
        }
    }
    
    function pBlue(value: number): number { 
        if (value <= 0) {
            return 0;
        } else if (value <= 63) {
            return Math.round(value * 328.968);
        } else if (value <= 127) {
            return 20725 + Math.round((value - 63) * 215.313);
        } else if (value <= 191) {
            return 34505 + Math.round((value - 127) * 385.969);
        } else {
            return 59207 + Math.round((value - 191) * 681.641);
        }
    }

    /**
     * image file reader
     * @param file single file from a FileList
     * @param callback function that will be called with an error or a response (result)
     */
    function read(file: Blob, callback: Function): void {
        const fileReader = new FileReader();
        fileReader.onload = () => callback(null, fileReader.result);
        fileReader.onerror = (err) => callback(err);
        fileReader.readAsDataURL(file);
    }

    function reset(): void {
        // reset variables
        calculated = false;
        totalPower = 0;
        totalPixels = 0;

        // reset canvas
        if (!context) return;
        context.clearRect(0, 0, canvas.width, canvas.height);
    }

    function calculatePower(): void {
        reset();

        if (!files || !files[0]) return;

        read(files[0], (
            err: ProgressEvent<FileReader>,
            res: string
        ) => {
            if (err) {
                console.log(err);
                return;
            }

            const image = new Image();
            image.crossOrigin = "anonymous";
            image.src = res;

            image.onload = function() {
                if (!context) return;

                canvas.width = image.width;
                canvas.height = image.height;
                context.drawImage(image, 0, 0);

                // get pixel data from image and loop through it
                const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
                const data = imageData.data;
                for (let i = 0; i < data.length; i += 4) {
                    totalPower += pRed(data[i]) + pGreen(data[i + 1]) + pBlue(data[i + 2]) + 67256;
                }

                totalPixels = image.width * image.height;
                calculated = true;
            };
        });
    }

    /* === LIFECYCLE ========================== */
    onMount(() => {
        context = canvas.getContext("2d");
        if (!context) console.log("failed to get context");
	});
</script>



<svelte:head>
    <title>OLED Display Power Consumption Calculator</title>
</svelte:head>

<h1>OLED Display Power Consumption Calculator</h1>
<form
    on:submit|preventDefault={calculatePower}
    on:reset={reset}>
    <label for="image">Choose an interface screenshot:</label>
    <input
        type="file"
        id="image"
        name="image"
        accept="image/png, image/jpeg"
        bind:files />
    <button>Submit</button>
    <button type="reset">Reset</button>
</form>

{#if calculated}
    <p style="font-weight: 600;">{totalPower / totalPixels} nW/pixel</p>
    <p>{totalPower} nW total consumption</p>
{/if}

<canvas bind:this={canvas}></canvas>