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

    /* === TYPES ============================== */
    type State =
        "loading"
        | "noContext" // cannot get 2D canvas context
        | "modelError" // cannot load face detection model
        | "ready"
        | "active";
    type Size = {
        width: number | null;
        height: number | null
    };
    type Rectangle = {
        originX: number;
        originY: number;
        width: number;
        height: number;
        rotation: number;
        drawnAt: DOMHighResTimeStamp;
    };

    /* === CONSTANTS ========================== */
    const timeToFade = 4000;
    const backgroundHue = 30;
    const backgroundSaturation = 100;
    const backgroundLightness = 44;
    const lightnessFadeSpeed = (100 - backgroundLightness) / timeToFade;

    /* === VARIABLES ========================== */
    let state: State = "loading";
    let faceDetector: FaceDetector;
    let supportsGetUserMedia = false;
    let videoSize: Size = {
        width: null,
        height: null
    };
    let videoPrevTime = -1;
    let canvasRatio: Size = {
        width: null,
        height: null
    }
    let rectangles: Rectangle[] = [];
    let confidence: number[] = [];

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

    function drawRectangle(
        rectangle: Rectangle,
        timestamp: DOMHighResTimeStamp
    ): void {
        if (!canvasRatio.width || !canvasRatio.height) return;
        const elapsedTime = timestamp - rectangle.drawnAt;
        context.save();

        context.fillStyle = `hsl(
            ${backgroundHue},
            ${backgroundSaturation}%,
            ${Math.max(100 - (elapsedTime * lightnessFadeSpeed), backgroundLightness)}%
        )`;

        if (
            rectangle.rotation !== 0 &&
            rectangle.rotation !== Math.PI
        ) {
            // rotate canvas context
            const centerX = (
                rectangle.originX + rectangle.width / 2
            ) * canvasRatio.width;
            const centerY = (
                rectangle.originY + rectangle.height / 2
            ) * canvasRatio.height;

            context.translate(centerX, centerY);
            context.rotate(rectangle.rotation);
            context.translate(-centerX, -centerY);
        }

        // draw rectangle
        context.fillRect(
            rectangle.originX * canvasRatio.width,
            rectangle.originY * canvasRatio.height,
            rectangle.width * canvasRatio.width,
            rectangle.height * canvasRatio.height
        );

        context.restore();
    }

    function renderNewFrame(
        detections: Detection[],
        timestamp: DOMHighResTimeStamp
    ): void {
        if (
            canvasRatio.width === null ||
            canvasRatio.height === null
        ) return;

        // clear canvas
        context.clearRect(0, 0, canvas.width, canvas.height);

        // draw background
        context.fillStyle = `hsl(
            ${backgroundHue},
            ${backgroundSaturation}%,
            ${backgroundLightness}%
        )`;
        context.fillRect(0, 0, canvas.width, canvas.height);

        let firstValidRectangle = 0;
        // draw all existing rectangles
        for (let i = 0; i < rectangles.length; i++) {
            const rectangle = rectangles[i];
            drawRectangle(rectangle, timestamp);

            if (rectangle.drawnAt + timeToFade <= timestamp) {
                // rectangle has faded out
                firstValidRectangle = i + 1;
            }
        }

        // remove all rectangles that have faded out
        if (firstValidRectangle > 0)
            rectangles = rectangles.slice(firstValidRectangle);

        if (videoSize.width === null) return;
        confidence = [];

        // go through new detections from this frame
        for(let i = 0; i < detections.length; i++) {
            const detection = detections[i];
            if (!detection.boundingBox) return;

            confidence.push(Math.round(detection.categories[0].score * 100));

            // get both eyes
            const leftEye = detection.keypoints[0];
            const rightEye = detection.keypoints[1];
            if (!leftEye || !rightEye) return;

            // set up values for drawing
            const flippedRotation = Math.PI - Math.atan2(
                rightEye.y - leftEye.y,
                rightEye.x - leftEye.x
            );
            const flippedX = videoSize.width - detection.boundingBox.originX - detection.boundingBox.width;

            // construct new rectangle
            const newRectangle: Rectangle = {
                originX: flippedX,
                originY: detection.boundingBox.originY,
                width: detection.boundingBox.width,
                height: detection.boundingBox.height,
                rotation: flippedRotation,
                drawnAt: timestamp
            };

            // add new rectangle to array and draw it
            rectangles.push(newRectangle);
            drawRectangle(newRectangle, timestamp);
        }
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
                window.requestAnimationFrame(predictWebcam);
            });
        } catch (err) {
            console.error(err);
        }
    }

    async function predictWebcam(timestamp: DOMHighResTimeStamp): Promise<void> {
        if (!video) return;
        if (video.currentTime === videoPrevTime) {
            // frame has alreay been drawn
            window.requestAnimationFrame(predictWebcam);
            return;
        }

        const startTimestamp = performance.now();
        videoPrevTime = video.currentTime;
        const res = faceDetector.detectForVideo(video, startTimestamp);

        renderNewFrame(res.detections, timestamp);

        window.requestAnimationFrame(predictWebcam);
    }

    /* === LIFECYCLE ========================== */
    onMount(async () => {
        handleResize();

        // get 2D canvas context
        const tempContext = canvas.getContext("2d", { alpha: false });
        if (!tempContext) {
            state = "noContext";
            return;
        }
        context = tempContext;

        // draw background
        context.fillStyle = `hsl(
            ${backgroundHue},
            ${backgroundSaturation}%,
            ${backgroundLightness}%
        )`;
        context.fillRect(0, 0, canvas.width, canvas.height);

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
    </div>
</main>



<style lang="scss">
    canvas {
        display: block;
        width: 100%;
        height: 100vh;

        background-color: #e07100;
    }

    .webcamView {
        position: relative;
        overflow: hidden;

        font-family: sans-serif;

        video {
            position: fixed;
            top: 0;
            left: 0;
            z-index: -1;
        }

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