<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import {
        type Detection,
        FilesetResolver,
        FaceDetector,
    } from '@mediapipe/tasks-vision';

    /* === BINDINGS =========================== */
    let video: HTMLVideoElement;

    /* === VARIABLES ========================== */
    let state = "loading";
    let faceDetector: FaceDetector;
    let supportsGetUserMedia = false;
    let videoPrevTime = -1;
    let detections: { detections: Detection[] };

    /* === FUNCTIONS ========================== */
    async function enableWebcam(): Promise<void> {
        if (!supportsGetUserMedia || !faceDetector) return;

        try {
            const stream = await navigator.mediaDevices.getUserMedia({
                video: true
            });
            // setup video element
            video.srcObject = stream;
            video.addEventListener("loadeddata", () => {
                state = "active";
                predictWebcam();
            });
        } catch (err) {
            console.error(err);
        }
    }

    async function predictWebcam(): Promise<void> {
        if (!video) return;
        const startTimestamp = performance.now();

        if (video.currentTime !== videoPrevTime) {
            videoPrevTime = video.currentTime;
            detections = faceDetector.detectForVideo(video, startTimestamp);
        }

        window.requestAnimationFrame(predictWebcam);
    }

    /* === LIFECYCLE ========================== */
    onMount(async () => {
        // load Mediapipe WASM
        const vision = await FilesetResolver.forVisionTasks(
            "https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision/wasm"
        );

        // load face detector model
        faceDetector = await FaceDetector.createFromOptions(
            vision,
            {
            baseOptions: {
                modelAssetPath: "/MediaPipe/blaze_face_short_range.tflite",
                delegate: "GPU"
            },
            runningMode: "VIDEO"
        });

        // check getUserMedia support
        supportsGetUserMedia = !!navigator.mediaDevices?.getUserMedia;

        state = "ready";
    });
</script>


<main>
    {#if state === "ready"}
        {#if supportsGetUserMedia}
            <button
                on:click={enableWebcam}>
                enable webcam
            </button>
        {:else}
            <p>Your browser does not support the use of webcams. Please try a different browser or device.</p>
        {/if}
    {:else if state === "loading"}
        <p>loading...</p>
    {/if}

    <div class="webcamView">
        <video bind:this={video} autoplay></video>
        {#if state === "active"}
            {#each detections.detections as detection}
                <p
                    class="text"
                    style="
                        left: {detection.boundingBox ? detection.boundingBox.originX : 0}px;
                        top: calc({detection.boundingBox ? detection.boundingBox.originY : 0}px - 1rem - 5px);
                    ">
                    Confidence: {Math.round(parseFloat(detection.categories[0].score.toString()) * 100)}%
                </p>
                <div
                    class="boundingBox"
                    style="
                        left: {detection.boundingBox ? detection.boundingBox.originX : 0}px;
                        top: {detection.boundingBox ? detection.boundingBox.originY : 0}px;
                        width: {detection.boundingBox ? detection.boundingBox.width : 0}px;
                        height: {detection.boundingBox ? detection.boundingBox.height : 0}px;
                    ">
                </div>

                {#each detection.keypoints as keypoint}
                    <div
                        class="boundingBox"
                        style="
                            left: {keypoint.x * video.offsetWidth - 4}px;
                            top: {keypoint.y * video.offsetHeight - 4}px;
                            width: 8px;
                            height: 8px;
                        ">
                    </div>
                {/each}
            {/each}
        {/if}
    </div>
</main>



<style lang="scss">
    main {
        display: flex;
        flex-flow: column nowrap;
        align-items: center;
        justify-content: center;
        height: 100vh;
    }

    .webcamView {
        position: relative;
        overflow: hidden;

        font-family: sans-serif;

        .text {
            position: absolute;
            color: #ffffff;
            font-size: 1rem;
            line-height: 1em;
        }

        .boundingBox {
            position: absolute;
            border: 2px solid #ffffff;
        }
    }
</style>