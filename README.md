# experiments

## What is this?

This is a collection of my miscellaneous side projects that are not large/complex enough to get their own repositories.

## Technical overview

These projects are built using [SvelteKit](https://kit.svelte.dev/), mostly written in [TypeScript](https://www.typescriptlang.org/), and styled with [Dart Sass](https://sass-lang.com/dart-sass). The production site is deployed using [Vercel](https://vercel.com/).

## Running these projects

Download or clone this repository. Ensure you have [Node.js](https://nodejs.org/en) installed, then enter the following into your terminal at this project’s root directory:

```bash
# install all npm packages and dependencies
npm i

# start a local development server
npm run dev

# create a production version (once you’re ready)
npm run build
```

# Project Overviews

## [Uganglobe](https://misc.richardfxr.com/uganglobe)

> Most files are available under [src\routes\uganglobe](https://github.com/richardfxr/misc/tree/main/src/routes/uganglobe) or prefixed with `UNG-` in [src\lib](https://github.com/richardfxr/misc/tree/main/src/lib).

Visualizing the countries of origin for refugees in Uganda. [Visit the production website](https://misc.richardfxr.com/uganglobe).

Data provided by the Government of Uganda through the [UNHCR Operational Data Portal](https://data.unhcr.org/en/country/uga).

3D globe created with [globe.gl](https://globe.gl/), a wrapper for the [three-globe](https://github.com/vasturiano/three-globe) plugin built on top of [ThreeJS](https://threejs.org/) and [WebGL](https://www.khronos.org/webgl/). Flags provided by [flag-icons](https://flagicons.lipis.dev/).

## [Scatter](https://misc.richardfxr.com/scatter)

> Most files are available under [src\routes\scatter](https://github.com/richardfxr/misc/tree/main/src/routes/scatter) or prefixed with `SCT-` in [src\lib](https://github.com/richardfxr/misc/tree/main/src/lib).

A simple page that scatters a specified number of points on the screen.

## [Hypnosis](https://misc.richardfxr.com/hypnosis)

> Most files are available under [src\routes\hypnosis](https://github.com/richardfxr/misc/tree/main/src/routes/hypnosis) or prefixed with `SHD-` in [src\lib](https://github.com/richardfxr/misc/tree/main/src/lib). The fragment shader can be found at [src\shaders\hypnosis.glsl](https://github.com/richardfxr/misc/blob/main/src/shaders/hypnosis.glsl)

A GLSL fragment shader rendered with WebGL with a few user-adjustable parameters.