<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import {
        type Detection,
        FilesetResolver,
        FaceDetector,
    } from '@mediapipe/tasks-vision';

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;
    let context: CanvasRenderingContext2D;
    let video: HTMLVideoElement;

    /* === VARIABLES ========================== */
    let state = "loading";
    let faceDetector: FaceDetector;
    let supportsGetUserMedia = false;
    let videoSize: { width: number | null; height: number | null } = {
        width: null,
        height: null
    };
    let videoPrevTime = -1;
    let canvasRatio: { width: number | null; height: number | null } = {
        width: null,
        height: null
    }
    let detections: { detections: Detection[] };

    /* === FUNCTIONS ========================== */
    function handleResize(): void {
        // get device pixel ratio
        const scale = window.devicePixelRatio;

        // update canvas size
        canvas.width = Math.floor(canvas.clientWidth * scale);
        canvas.height = Math.floor(canvas.clientHeight * scale);

        if (videoSize.width === null || videoSize.height === null) return;

        // update canvas ratio
        canvasRatio.width = canvas.width / videoSize.width;
        canvasRatio.height = canvas.height / videoSize.height;
    }

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
                // set video size and calculate canvas ratio
                videoSize = {
                    width: video.offsetWidth,
                    height: video.offsetHeight
                };
                handleResize();
                predictWebcam();
            });
        } catch (err) {
            console.error(err);
        }
    }

    async function predictWebcam(): Promise<void> {
        if (!video) return;
        if (video.currentTime === videoPrevTime) {
            // frame has alreay been drawn
            window.requestAnimationFrame(predictWebcam);
            return;
        }

        const startTimestamp = performance.now();
        videoPrevTime = video.currentTime;
        detections = faceDetector.detectForVideo(video, startTimestamp);

        context.fillStyle = 'rgba(0, 0, 0, 0.01)';
        context.fillRect(0, 0, canvas.width, canvas.height);

        detections.detections.forEach(detection => {
            if (
                !detection.boundingBox ||
                videoSize.width === null ||
                videoSize.height === null ||
                canvasRatio.width === null ||
                canvasRatio.height === null
            ) return;

            // get head rotation
            const leftEye = detection.keypoints[0];
            const rightEye = detection.keypoints[1];
            if (!leftEye || !rightEye) return;
            const flippedRotation = Math.PI - Math.atan2(
                rightEye.y - leftEye.y,
                rightEye.x - leftEye.x
            );

            // set up values for drawing
            const flippedX = videoSize.width - detection.boundingBox.originX - detection.boundingBox.width;
            context.fillStyle = "#ffffff";

            if (flippedRotation === 0 || flippedRotation === Math.PI) {
                // no rotation, simply draw rectangle
                context.fillRect(
                    flippedX * canvasRatio.width,
                    detection.boundingBox.originY * canvasRatio.height,
                    detection.boundingBox.width * canvasRatio.width,
                    detection.boundingBox.height * canvasRatio.height
                );
            } else {
                // rotate the draw rectangle
                context.save();
                context.translate(
                    (flippedX + detection.boundingBox.width / 2) * canvasRatio.width,
                    (detection.boundingBox.originY + detection.boundingBox.height / 2) * canvasRatio.height
                );
                context.rotate(flippedRotation);
                context.translate(
                    -(flippedX + detection.boundingBox.width / 2) * canvasRatio.width,
                    -(detection.boundingBox.originY + detection.boundingBox.height / 2) * canvasRatio.height
                );
                context.fillRect(
                    flippedX * canvasRatio.width,
                    detection.boundingBox.originY * canvasRatio.height,
                    detection.boundingBox.width * canvasRatio.width,
                    detection.boundingBox.height * canvasRatio.height
                );
                context.restore();
            }
        });

        window.requestAnimationFrame(predictWebcam);
    }

    /* === LIFECYCLE ========================== */
    onMount(async () => {
        handleResize();

        // get 2D canvas context
        const tempContext = canvas.getContext("2d");
        if (!tempContext) {
            state = "noContext";
            return;
        }
        context = tempContext;

        try {
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
        } catch (error) {
            state = "modelError";
        }
        
        // check getUserMedia support
        supportsGetUserMedia = !!navigator.mediaDevices?.getUserMedia;

        state = "ready";
    });
</script>



<svelte:window on:resize={handleResize}/>

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
    {:else if state === "noContext"}
        <p>Failed to get canvas context. Please reload.</p>
    {:else if state === "modelError"}
        <p>Failed to load face detection model. Please reload.</p>
    {:else if state === "loading"}
        <p>loading...</p>
    {/if}

    <canvas bind:this={canvas}></canvas>

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
    canvas {
        display: block;
        width: 100%;
        height: 100vh;

        background-color: #000000;
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