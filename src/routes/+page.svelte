<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import Image from "$lib/image.svelte";

    /* === LIFECYCLES ========================= */
    onMount(() => {
        // update meta theme-color based on color scheme and contrast
		if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
            if (window.matchMedia("(prefers-contrast: more)").matches) {
                document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#000000");
            } else {
                document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#161616");
            }
        } else if (window.matchMedia("(prefers-contrast: more)").matches) {
            document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#ffffff");
        }

        window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", e => {
            if (e.matches) {
                if (window.matchMedia("(prefers-contrast: more)").matches) {
                    document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#000000");
                } else {
                    document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#161616");
                }
            } else {
                if (window.matchMedia("(prefers-contrast: more)").matches) {
                    document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#ffffff");
                } else {
                    document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#ededed");
                }
            }
        });

        window.matchMedia("(prefers-contrast: more)").addEventListener("change", e => {
            if (e.matches) {
                if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
                    document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#000000");
                } else {
                    document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#ffffff");
                }
            } else {
                if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
                    document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#161616");
                } else {
                    document.querySelector("meta[name='theme-color']")?.setAttribute("content", "#ededed");
                }
            }
        });
	});
</script>



<svelte:head>
    <title>Experiments by Richard Fu</title>
    <meta
        name="description"
        content="A collection of technical and creative explorations made to gauge the capabilities and limitations of the web as a medium."
    />
    <link rel="icon" href="favicon.png" />
    <meta name="theme-color" content="#ededed" />
    <!-- open graph image -->
    <meta property="og:image" content="/SHD-og-image-1.jpg" />
    <meta property="og:image:type" content="image/jpeg" />
    <meta property="og:image:width" content="1200" />
    <meta property="og:image:height" content="630" />
    <meta property="og:image:alt" content="Concentric circles emerging from the center, changing color as they move further away." />
</svelte:head>

<main>
    <div class="hero">
        <h1>experiments</h1>
        <div class="paragraphs">
            <p>A collection of technical and creative explorations by <a href="https://www.richardfxr.com/" target="_blank" rel="noopener noreferrer">Richard Fu</a>. They were created to gauge the capabilities and limitations of the web as a medium.</p>
            <p>The source code for all experiments are available in the <a href="https://github.com/richardfxr/experiments" target="_blank" rel="noopener noreferrer">richardfxr/experiments GitHub repository</a>.</p>
        </div>
    </div>

    <ul class="experiments">
        <li>
            <a
                data-sveltekit-reload
                href="/pixel-viewer">
                <h2>Pixel Viewer</h2>
                <p>An image viewer with customizable mouse, trackpad, and touch interactions.</p>
                <Image
                    src="/images/index/PXL-thumbnail"
                    alt="A square grid of six by six pixels fading from black to yellow." />
            </a>
        </li>

        <li>
            <a
                data-sveltekit-reload
                href="/hypnosis">
                <h2>Hypnosis</h2>
                <p>An interactive GLSL fragment shader rendered with WebGL.</p>
                <Image
                    src="/images/index/SHD-thumbnail"
                    alt="Concentric circles centered on the screen, changing color as they move away from the center." />
            </a>
        </li>

        <li>
            <a
                data-sveltekit-reload
                href="/scatter">
                <h2>Scatter</h2>
                <p>A pseudo-random number generator that scatters points across the screen. </p>
                <Image
                    src="/images/index/SCT-thumbnail"
                    alt="Eight points scatter randomly across the screen, each connected to the center through a straight line." />
            </a>
        </li>

        <li>
            <a
                data-sveltekit-reload
                href="/uganglobe">
                <h2>Uganda Refugee Data Viz</h2>
                <p>Uganda refugee countries of origin data visualized on a globe.</p>
                <Image
                    src="/images/index/UGN-thumbnail"
                    alt="Three-dimensional globe with multiple orange arches connecting other countries to Uganda." />
            </a>
        </li>
    </ul>
</main>

<footer>
    <p>© 2024 Xiangrui Fu. All rights reserved.</p>
    <ul aria-label="External links.">
        <li>
            <a
                href="https://www.richardfxr.com/"
                target="_blank"
                rel="noopener noreferrer">
                Portfolio
            </a>
        </li>
        <li>
            <a
                href="https://github.com/richardfxr"
                target="_blank"
                rel="noopener noreferrer">
                GitHub
            </a>
        </li>
    </ul>
</footer>



<style lang="scss">
    // === INTERNAL VARIABLES ====================
    $_border-width: 1px;
    $_border: solid $_border-width var(--clr-border);
    $_grid-gap: calc(0.2 * var(--pad-section-inline));
    $_trans-fast: 0.1s ease;

    /* === VARIABLES ========================== */
    :root {
        /* Colors */
        --clr-1000: #000000;
        --clr-900: #1b1b1b;
        --clr-600: #6B6B6B;
        --clr-0: #ffffff;
        --clr-border: #cccccc;
        --clr-bg: #ededed;

        color-scheme: light;

        /* Spacing */
        --pad-xl: 80px;
        --pad-outer-inline: 30px;
        --pad-section-inline: 20px;
    }

    @media (prefers-contrast: more) {
        :root {
            /* Colors */
            --clr-1000: #000000;
            --clr-900: #1b1b1b;
            --clr-600: #4D4D4D;
            --clr-0: #ffffff;
            --clr-border: #858585;
            --clr-bg: #ffffff;
        }
    }

    @media (prefers-color-scheme: dark) {
        :root {
            /* Colors */
            --clr-1000: #ffffff;
            --clr-900: #ececec;
            --clr-600: #aaaaaa;
            --clr-0: #000000;
            --clr-border: #3a3a3a;
            --clr-bg: #161616;

            color-scheme: dark;
        }
    }

    @media (prefers-color-scheme: dark) and (prefers-contrast: more) {
        :root {
            /* Colors */
            --clr-1000: #ffffff;
            --clr-900: #ececec;
            --clr-600: #aaaaaa;
            --clr-0: #000000;
            --clr-border: #5E5E5E;
            --clr-bg: #000000;
        }
    }

    /* === MAIN =============================== */
    :global(body) {
        color: var(--clr-600);
        font-family: 'General Sans';
        font-weight: 400;
        font-size: 1rem;
        line-height: 1.4em;
        background-color: var(--clr-bg);
    }

    main, footer {
        max-width: 1500px;
        margin-inline: auto;
    }

    main {
        padding-inline: var(--pad-outer-inline);
    }

    .hero .paragraphs a, footer a {
        text-decoration: underline;
        transition: color $_trans-fast,
                    background-color $_trans-fast;

        &:hover, &:focus {
            color: var(--clr-1000);
        }

        &:active, &:focus-visible {
            color: var(--clr-0);
            background-color: var(--clr-900);
        }
    }

    .hero {
        padding-block: var(--pad-xl);
        padding-inline: var(--pad-section-inline);

        h1 {
            color: var(--clr-1000);
            font-family: 'Clash Grotesk';
            font-weight: 500;
            font-size: 3.5rem;
            line-height: 1.1em;

            margin-block-end: 0.45em;
        }

        .paragraphs {
            display: flex;
            flex-flow: row wrap;
            justify-content: space-between;
            column-gap: 50px;
            row-gap: 1em;

            p {
                &:first-child {
                    max-width: 53ch;
                }
                
                &:last-child {
                    max-width: 43ch;
                }
            }
        }
    }

    .experiments {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        align-items: stretch;

        border-block-start: $_border;
        border-block-end: $_border;

        li {
            position: relative;
            padding-block: calc(0.3 * var(--pad-section-inline));
            padding-inline: $_grid-gap;
            border-block-end: $_border;
            margin-block-end: -$_border-width;
            
            &::before {
                content: "";
                position: absolute;
                inset-block: 0;
                inset-inline-end: calc(-0.5 * $_grid-gap);
                border-inline-end: $_border;
            }

            &:nth-child(3n + 1) {
                padding-inline-start: 0;
                padding-inline-end: calc(2 * $_grid-gap);

                &::before {
                    inset-inline-end: calc(0.5 * $_grid-gap);
                }
            }

            &:nth-child(3n) {
                padding-inline-start: calc(2 * $_grid-gap);
                padding-inline-end: 0;

                &::before {
                    display: none;
                }
            }
        }

        a {
            display: flex;
            flex-flow: column nowrap;
            height: 100%;

            padding-block-start: calc(1.8 * var(--pad-section-inline));
            padding-block-end: calc(2.4 * var(--pad-section-inline));
            padding-inline: var(--pad-section-inline);
            border-radius: 4px;
            outline: solid 2px transparent;

            transition: background-color $_trans-fast,
                        outline-color $_trans-fast;

            &:hover, &:focus {
                background-color: var(--clr-0);
            }

            &:active, &:focus-visible {
                outline-color: var(--clr-900);
            }
        }

        h2 {
            color: var(--clr-1000);
            font-family: 'Clash Grotesk';
            font-size: 1rem;
            font-weight: 600;
        }

        p {
            margin-block-end: calc(1.2 * var(--pad-section-inline));
        }

        :global(picture) {
            margin-block-start: auto;
            border: $_border;
        }
    }

    footer {
        display: flex;
        flex-flow: row wrap;
        column-gap: 5ch;
        row-gap: 8px;
        justify-content: space-between;

        padding-block-start: var(--pad-xl);
        padding-block-end: 35px;
        padding-inline: calc(var(--pad-outer-inline) + var(--pad-section-inline));

        ul {
            display: flex;
            flex-flow: row wrap;
            column-gap: 4ch;
            row-gap: 8px;
        }
    }

    /* === BREAKPOINTS ======================== */
    @media (max-width: 1200px) {
        :root {
            /* Spacing */
            --pad-xl: 70px;
            --pad-outer-inline: 26px;
            --pad-section-inline: 18px;
        }

        .hero {
            h1 {
                font-size: 3.2rem;
            }
        }

        .experiments {
            grid-template-columns: 1fr 1fr;

            li {
                padding-inline: calc(1.5 * $_grid-gap);

                &::before {
                    inset-inline-end: 0;
                }

                &:nth-child(3n + 1), &:nth-child(3n) {
                    padding-inline-start: calc(1.5 * $_grid-gap);
                    padding-inline-end: calc(1.5 * $_grid-gap);

                    &::before {
                        display: block;
                        inset-inline-end: 0;
                    }
                }

                &:nth-child(2n + 1) {
                    padding-inline-start: 0;
                }

                &:nth-child(2n) {
                    padding-inline-end: 0;
                    
                    &::before {
                        display: none;
                    }
                }
            }
        }
    }

    @media (max-width: 950px) {
        :root {
            /* Spacing */
            --pad-xl: 63px;
            --pad-outer-inline: 22px;
            --pad-section-inline: 16px;
        }

        .hero {
            h1 {
                font-size: 3rem;
            }
        }
    }

    @media (max-width: 700px) {
        :root {
            /* Spacing */
            --pad-xl: 58px;
            --pad-outer-inline: 18px;
            --pad-section-inline: 14px;
        }

        .hero {
            h1 {
                font-size: 2.8rem;
            }
        }
    }

    @media (max-width: 670px) {
        :root {
            /* Spacing */
            --pad-xl: 54px;
            --pad-outer-inline: 12px;
        }

        .hero {
            h1 {
                font-size: 2.6rem;
            }
        }

        .experiments {
            display: block;

            li {
                padding-block: calc(0.5 * var(--pad-section-inline));
                padding-inline: 0;

                &::before {
                    display: none;
                }

                &:nth-child(3n + 1), &:nth-child(3n),
                &:nth-child(2n + 1), &:nth-child(2n) {
                    padding-inline-start: 0;
                    padding-inline-end: 0;

                    &::before {
                        display: none;
                    }
                }
            }
        }
    }

    @media (max-width: 450px) {
        :root {
            /* Spacing */
            --pad-xl: 50px;
            --pad-outer-inline: 10px;
        }

        .hero {
            h1 {
                font-size: 2.4rem;
            }
        }
    }

    @media (max-width: 350px) {
        :root {
            /* Spacing */
            --pad-xl: 50px;
            --pad-outer-inline: 8px;
        }

        .hero {
            h1 {
                font-size: 2.3rem;
            }
        }
    }
</style>