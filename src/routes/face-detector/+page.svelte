<script lang="ts" context="module">
    /* === TYPES ============================== */
    export type State =
        "loading" |
        "noWebcam" |
        "noContext" | // cannot get 2D canvas context
        "modelError" | // cannot load face detection model
        "ready" |
        "active";
</script>

<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import { slide } from 'svelte/transition';
    import { quintOut } from 'svelte/easing';
    import {
        type Detection,
        FilesetResolver,
        FaceDetector,
    } from '@mediapipe/tasks-vision';
    import MainIllus from '$lib/SVGs/FCE-mainIllus.svelte';

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;
    let context: CanvasRenderingContext2D;
    let video: HTMLVideoElement;

    /* === TYPES ============================== */
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
    const slideParams = { duration: 300, easing: quintOut};

    /* === VARIABLES ========================== */
    let state: State = "loading";
    let loadingWebcam = false;
    let faceDetector: FaceDetector;
    let supportsGetUserMedia = false;
    let animationRequestId: number;
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
    let numFaces: number = 0;

    /* === FUNCTIONS ========================== */
    function readyUp(): void {
        // check getUserMedia support
        supportsGetUserMedia = !!navigator.mediaDevices?.getUserMedia;

        if (supportsGetUserMedia)
            state = "ready";
        else
            state = "noWebcam";
    }

    function drawCanvasBackground(): void {
        if (!context) return;

        context.fillStyle = `hsl(
            ${backgroundHue},
            ${backgroundSaturation}%,
            ${backgroundLightness}%
        )`;
        context.fillRect(0, 0, canvas.width, canvas.height);
    }

    function handleResize(): void {
        // get device pixel ratio
        const scale = window.devicePixelRatio;

        // update canvas size
        canvas.width = Math.floor(canvas.clientWidth * scale);
        canvas.height = Math.floor(canvas.clientHeight * scale);
        drawCanvasBackground();

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
        drawCanvasBackground();

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
        numFaces = detections.length;

        // go through new detections from this frame
        for(let i = 0; i < detections.length; i++) {
            const detection = detections[i];
            if (!detection.boundingBox) return;

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
        loadingWebcam = true;

        try {
            const stream = await navigator.mediaDevices.getUserMedia({
                video: true
            });
            // setup video element
            video.srcObject = stream;
            video.addEventListener("loadeddata", () => {
                state = "active";
                loadingWebcam = false;
                // set video size and calculate canvas ratio
                videoSize = {
                    width: video.offsetWidth,
                    height: video.offsetHeight
                };
                handleResize();
                animationRequestId = window.requestAnimationFrame(predictWebcam);
            });
        } catch (err) {
            state = "noWebcam";
        }
    }

    function predictWebcam(timestamp: DOMHighResTimeStamp): void {
        if (!video || state !== "active") return;
        if (video.currentTime === videoPrevTime) {
            // frame has alreay been drawn
            animationRequestId = window.requestAnimationFrame(predictWebcam);
            return;
        }

        const startTimestamp = performance.now();
        videoPrevTime = video.currentTime;
        const res = faceDetector.detectForVideo(video, startTimestamp);

        renderNewFrame(res.detections, timestamp);

        animationRequestId = window.requestAnimationFrame(predictWebcam);
    }

    function stopWebcam(): void {
        if (!video || !video.srcObject) return;

        state="loading";

        // cancel animation frame
        window.cancelAnimationFrame(animationRequestId);

        // stop every track in the stream
        const stream = video.srcObject as MediaStream;
        stream.getTracks().forEach((track) => {
            track.stop();
        });

        // reset values
        video.srcObject = null;
        loadingWebcam = false;
        rectangles = [];

        readyUp();
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
        drawCanvasBackground();

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
        
        readyUp();
    });
</script>



<svelte:window on:resize={handleResize}/>

<main class={state}>
    <div class="wrapper">
        <div class="ui">
            {#if state === "active"}
                <div class="controls">
                    <button
                        class="button"
                        on:click={stopWebcam}>
                        <div class="square"></div>
                        Stop
                    </button>
                    <p>{numFaces.toString()} {numFaces === 1 ? 'face' : 'faces'}</p>
                </div>
            {:else}
                <MainIllus {state} />
                <div class="h1Container">
                    <h1>
                        {#if state === "ready"}
                            Face Draw
                        {:else if state === "loading"}
                            Loading
                        {:else}
                            Error
                        {/if}
                    </h1>
                </div>
                

                {#if state === "ready"}
                    <p transition:slide={slideParams}>
                        This experiment uses a <a href="https://developers.google.com/mediapipe" target="_blank" rel="noopener noreferrer">Google MediaPipe</a> model for face detection. Input data is processed locally. No data is shared.
                    </p>
                    <button
                        class="button"
                        on:click={enableWebcam}
                        transition:slide={slideParams}>
                        <div class="circle"></div>
                        {loadingWebcam ? `Starting` : `Enable camera`}
                    </button>
                {:else if state === "noWebcam"}
                    <p transition:slide={slideParams}>
                        Failed to access camera. Please reload. If the issue persists, try a different browser or device.
                    </p>
                {:else if state === "noContext"}
                    <p transition:slide={slideParams}>
                        Failed to load canvas context. Please reload. If the issue persists, try a different browser.
                    </p>
                {:else if state === "modelError"}
                    <p transition:slide={slideParams}>
                        Failed to load face detection model. Please reload. If the issue persists, try a different browser.
                    </p>
                {/if}
            {/if}
        </div>
    </div>

    <canvas bind:this={canvas}></canvas>

    <div class="webcamView">
        <video bind:this={video} autoplay></video>
    </div>
</main>



<style lang="scss">
    :root {
        --FCE-clr-1000: #ffffff;
        --FCE-clr-900: #fff3e7;
        --FCE-clr-800: #ffe6cc;
        --FCE-clr-600: #eb9e4e;
        --FCE-clr-300: #452300;
        --FCE-clr-200: #311c08;
        --FCE-clr-100: #1d1207;
        --FCE-clr-bg: #e07100;
        --FCE-border-width: 1px;
        --FCE-transition-fast: 0.2s ease-in-out;
    }

    main {
        position: relative;

        font-family: 'General Sans', sans-serif;
        background-color: var(--FCE-clr-bg);

        &.active {
            .wrapper {
                justify-content: flex-start;
                background-color: transparent;
                padding: 0;
            }

            .ui {
                .controls {
                    display: flex;
                    flex-flow: row wrap;
                    background-color: var(--FCE-clr-bg);

                    .button {
                        gap: 8px;
                        width: auto;
                        font-size: 1rem;
                        padding: 8px 17px;
                        margin-top: 0;
                    }

                    p {
                        flex-grow: 1;
                        display: flex;
                        align-items: center;

                        padding: 8px 17px;
                        border: solid var(--FCE-border-width) var(--FCE-clr-600);
                        margin-top: 0;
                    }
                }
            }
        }
    }

    .wrapper {
        display: flex;
        flex-flow: column nowrap;
        align-items: center;
        justify-content: center;

        position: absolute;
        top: 0;
        right: 0;
        left: 0;
        min-height: 100vh;

        padding: 20px 0;
        background-color: var(--FCE-clr-bg);
    }

    .ui {
        width: 50%;
        max-width: 500px;

        .h1Container {
            display: flex;
            justify-content: center;
            border: solid var(--FCE-border-width) var(--FCE-clr-600);
            background-image: radial-gradient(circle at 4px 5px, var(--FCE-clr-600) 1px, transparent 0);
            background-size: 10px 10px;
            margin-top: 10px;
            
            h1 {
                font-size: 1.4rem;
                font-weight: 500;
                color: var(--FCE-clr-1000);
                padding: 7px 15px;
                background-color: var(--FCE-clr-bg);
                border-right: solid var(--FCE-border-width) var(--FCE-clr-600);
                border-left: solid var(--FCE-border-width) var(--FCE-clr-600);
            }
        }

        p {
            color: var(--FCE-clr-1000);
            font-size: 1rem;
            font-weight: 400;
            line-height: 1.3em;
            text-align: center;
            margin-top: 20px;

            a {
                text-decoration: underline;
            }
        }

        .button {
            display: flex;
            flex-flow: row wrap;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;

            color: var(--FCE-clr-300);
            font-size: 1.2rem;
            font-weight: 600;
            padding: 12px 25px;
            background-color: var(--FCE-clr-800);
            margin-top: 20px;

            transition: color var(--FCE-transition-fast),
                        background-color var(--FCE-transition-fast);

            &:hover, &:focus {
                color: var(--FCE-clr-200);
                background-color: var(--FCE-clr-900);
            }
            
            &:active {
                color: var(--FCE-clr-100);
                background-color: var(--FCE-clr-1000);
            }

            &:focus-visible {
                outline: 1px solid var(--FCE-clr-1000);
                outline-offset: 3px;
            }

            .circle, .square {
                background-color: var(--FCE-clr-300);
            }

            .square {
                width: 12px;
                height: 12px;
            }

            .circle {
                width: 14px;
                height: 14px;
                border-radius: 30px;
            }
        }
    }

    canvas {
        display: block;
        width: 100%;
        height: 100vh;
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
    }

    /* === BREAKPOINTS ======================== */
    @media (max-width: 720px) {
        .ui {
            width: 55%;
        }
    }

    @media (max-width: 630px) {
        .ui {
            width: 68%;
        }
    }

    @media (max-width: 520px) {
        .ui {
            width: 80%;
        }
    }

    @media (max-width: 400px) {
        .ui {
            width: 90%;
        }
    }
</style>