<script lang="ts">
    /* === IMPORTS ============================ */
    import * as THREE from 'three';
    import type { SvelteComponent } from "svelte";
    import {
        totalNeighborhoods,
        neighborhoodSize,
        neighborhoodCenter,
        neighborhoodTotalCells,
        neighboorhoodMiddleIndex
    } from "$lib/MNCA-controls.svelte";
    import Canvas from "$lib/MNCA-canvas.svelte";
    import Controls from "$lib/MNCA-controls.svelte";
    import RuleIcon from "$lib/SVGs/MNCA-rule.svelte";

    /* === BINDINGS =========================== */
    let controls: SvelteComponent;

    /* === VARIABLES ========================== */
    let fps = 0;
    let neighborhoodALength = 108;
    let neighborhoodBLength = 36;
    let neighborhoodCLength = 20;
    let neighborhoodDLength = 80;
    // whether the neighborhood is enabled or not
    let neighborhoodStates: boolean[] = Array(totalNeighborhoods).fill(true);
    // Multiple Neighborhood Cellular Automaton neighborhoods shapes
    // 224 element arrays (15 x 15 without center cell)
    // true = cell is part of neighborhood, false otherwise
    let neighborhoodShapes: boolean[][] = [
        [false,false,false,false,false,true,true,true,true,true,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true,true,false,false,false,false,false,true,true,true,true,true,true,true,true,true,true,true,false,false,false,true,true,true,true,false,false,false,false,false,true,true,true,true,false,false,true,true,true,false,false,false,false,false,false,false,true,true,true,false,true,true,true,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,false,false,false,false,false,false,false,false,true,true,true,true,true,true,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,false,false,false,false,false,false,false,false,false,true,true,true,false,true,true,true,false,false,false,false,false,false,false,true,true,true,false,false,true,true,true,true,false,false,false,false,false,true,true,true,true,false,false,false,true,true,true,true,true,true,true,true,true,true,true,false,false,false,false,false,true,true,true,true,true,true,true,true,true,false,false,false,false,false,false,false,false,true,true,true,true,true,false,false,false,false,false],
        [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,false,false,false,false,false,false,false,false,true,true,true,true,true,true,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,false,false,false,false,false,false,false,false,false,true,true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],
        [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,false,false,false,false,false,false,false,false,false,false,true,true,true,true,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],
        [false,false,false,false,false,true,true,true,true,true,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true,true,false,false,false,false,false,true,true,true,false,false,false,false,false,true,true,true,false,false,false,true,true,true,false,false,false,false,false,false,false,true,true,true,false,false,true,true,false,false,false,false,false,false,false,false,false,true,true,false,true,true,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,false,false,false,false,false,false,false,false,false,false,true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,true,true,false,true,true,false,false,false,false,false,false,false,false,false,true,true,false,false,true,true,true,false,false,false,false,false,false,false,true,true,true,false,false,false,true,true,true,false,false,false,false,false,true,true,true,false,false,false,false,false,true,true,true,true,true,true,true,true,true,false,false,false,false,false,false,false,false,true,true,true,true,true,false,false,false,false,false]
    ];
    // Multiple Neighborhood Cellular Automaton neighborhoods
    // (x, y) represents relative location to current cell
    // filled with (0, 0) if shorter than 224 elements (15 x 15 without center cell)
    // set based on output from Controls ($lib/MNCA-controls.svelte)
    let neighborhoodA = [
        new THREE.Vector2(-2, -7), new THREE.Vector2(-1, -7), new THREE.Vector2(0, -7), new THREE.Vector2(1, -7), new THREE.Vector2(2, -7),
        new THREE.Vector2(-4, -6), new THREE.Vector2(-3, -6), new THREE.Vector2(-2, -6), new THREE.Vector2(-1, -6), new THREE.Vector2(0, -6), new THREE.Vector2(1, -6), new THREE.Vector2(2, -6), new THREE.Vector2(3, -6), new THREE.Vector2(4, -6),
        new THREE.Vector2(-5, -5), new THREE.Vector2(-4, -5), new THREE.Vector2(-3, -5), new THREE.Vector2(-2, -5), new THREE.Vector2(-1, -5), new THREE.Vector2(0, -5), new THREE.Vector2(1, -5), new THREE.Vector2(2, -5), new THREE.Vector2(3, -5), new THREE.Vector2(4, -5), new THREE.Vector2(5, -5),
        new THREE.Vector2(-6, -4), new THREE.Vector2(-5, -4), new THREE.Vector2(-4, -4), new THREE.Vector2(-3, -4), new THREE.Vector2(3, -4), new THREE.Vector2(4, -4), new THREE.Vector2(5, -4), new THREE.Vector2(6, -4),
        new THREE.Vector2(-6, -3), new THREE.Vector2(-5, -3), new THREE.Vector2(-4, -3), new THREE.Vector2(4, -3), new THREE.Vector2(5, -3), new THREE.Vector2(6, -3),
        new THREE.Vector2(-7, -2), new THREE.Vector2(-6, -2), new THREE.Vector2(-5, -2), new THREE.Vector2(5, -2), new THREE.Vector2(6, -2), new THREE.Vector2(7, -2),
        new THREE.Vector2(-7, -1), new THREE.Vector2(-6, -1), new THREE.Vector2(-5, -1), new THREE.Vector2(5, -1), new THREE.Vector2(6, -1), new THREE.Vector2(7, -1),
        new THREE.Vector2(-7, 0), new THREE.Vector2(-6, 0), new THREE.Vector2(-5, 0), new THREE.Vector2(5, 0), new THREE.Vector2(6, 0), new THREE.Vector2(7, 0),
        new THREE.Vector2(-7, 1), new THREE.Vector2(-6, 1), new THREE.Vector2(-5, 1), new THREE.Vector2(5, 1), new THREE.Vector2(6, 1), new THREE.Vector2(7, 1),
        new THREE.Vector2(-7, 2), new THREE.Vector2(-6, 2), new THREE.Vector2(-5, 2), new THREE.Vector2(5, 2), new THREE.Vector2(6, 2), new THREE.Vector2(7, 2),
        new THREE.Vector2(-6, 3), new THREE.Vector2(-5, 3), new THREE.Vector2(-4, 3), new THREE.Vector2(4, 3), new THREE.Vector2(5, 3), new THREE.Vector2(6, 3),
        new THREE.Vector2(-6, 4), new THREE.Vector2(-5, 4), new THREE.Vector2(-4, 4), new THREE.Vector2(-3, 4), new THREE.Vector2(3, 4), new THREE.Vector2(4, 4), new THREE.Vector2(5, 4), new THREE.Vector2(6, 4),
        new THREE.Vector2(-5, 5), new THREE.Vector2(-4, 5), new THREE.Vector2(-3, 5), new THREE.Vector2(-2, 5), new THREE.Vector2(-1, 5), new THREE.Vector2(0, 5), new THREE.Vector2(1, 5), new THREE.Vector2(2, 5), new THREE.Vector2(3, 5), new THREE.Vector2(4, 5), new THREE.Vector2(5, 5),
        new THREE.Vector2(-4, 6), new THREE.Vector2(-3, 6), new THREE.Vector2(-2, 6), new THREE.Vector2(-1, 6), new THREE.Vector2(0, 6), new THREE.Vector2(1, 6), new THREE.Vector2(2, 6), new THREE.Vector2(3, 6), new THREE.Vector2(4, 6),
        new THREE.Vector2(-2, 7), new THREE.Vector2(-1, 7), new THREE.Vector2(0, 7), new THREE.Vector2(1, 7), new THREE.Vector2(2, 7),
        // fill in array to be 224 in length
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0)
    ];
    let neighborhoodB = [
        new THREE.Vector2(-1, -3), new THREE.Vector2(0, -3), new THREE.Vector2(1, -3),
        new THREE.Vector2(-2, -2), new THREE.Vector2(-1, -2), new THREE.Vector2(0, -2), new THREE.Vector2(1, -2), new THREE.Vector2(2, -2),
        new THREE.Vector2(-3, -1), new THREE.Vector2(-2, -1), new THREE.Vector2(-1, -1), new THREE.Vector2(0, -1), new THREE.Vector2(1, -1), new THREE.Vector2(2, -1), new THREE.Vector2(3, -1),
        new THREE.Vector2(-3, 0), new THREE.Vector2(-2, 0), new THREE.Vector2(-1, 0), new THREE.Vector2(1, 0), new THREE.Vector2(2, 0), new THREE.Vector2(3, 0),
        new THREE.Vector2(-3, 1), new THREE.Vector2(-2, 1), new THREE.Vector2(-1, 1), new THREE.Vector2(0, 1), new THREE.Vector2(1, 1), new THREE.Vector2(2, 1), new THREE.Vector2(3, 1),
        new THREE.Vector2(-2, 2), new THREE.Vector2(-1, 2), new THREE.Vector2(0, 2), new THREE.Vector2(1, 2), new THREE.Vector2(2, 2),
        new THREE.Vector2(-1, 3), new THREE.Vector2(0, 3), new THREE.Vector2(1, 3),
        // fill in array to be 224 in length
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0)
    ];
    let neighborhoodC = [
        new THREE.Vector2(-1, -2), new THREE.Vector2(0, -2), new THREE.Vector2(1, -2),
        new THREE.Vector2(-2, -1), new THREE.Vector2(-1, -1), new THREE.Vector2(0, -1), new THREE.Vector2(1, -1), new THREE.Vector2(2, -1),
        new THREE.Vector2(-2, 0), new THREE.Vector2(-1, 0), new THREE.Vector2(1, 0), new THREE.Vector2(2, 0),
        new THREE.Vector2(-2, 1), new THREE.Vector2(-1, 1), new THREE.Vector2(0, 1), new THREE.Vector2(1, 1), new THREE.Vector2(2, 1),
        new THREE.Vector2(-1, 2), new THREE.Vector2(0, 2), new THREE.Vector2(1, 2),
        // fill in array to be 224 in length
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0)
    ];
    let neighborhoodD = [
        new THREE.Vector2(-2, -7), new THREE.Vector2(-1, -7), new THREE.Vector2(0, -7), new THREE.Vector2(1, -7), new THREE.Vector2(2, -7),
        new THREE.Vector2(-4, -6), new THREE.Vector2(-3, -6), new THREE.Vector2(-2, -6), new THREE.Vector2(-1, -6), new THREE.Vector2(0, -6), new THREE.Vector2(1, -6), new THREE.Vector2(2, -6), new THREE.Vector2(3, -6), new THREE.Vector2(4, -6),
        new THREE.Vector2(-5, -5), new THREE.Vector2(-4, -5), new THREE.Vector2(-3, -5), new THREE.Vector2(3, -5), new THREE.Vector2(4, -5), new THREE.Vector2(5, -5),
        new THREE.Vector2(-6, -4), new THREE.Vector2(-5, -4), new THREE.Vector2(-4, -4), new THREE.Vector2(4, -4), new THREE.Vector2(5, -4), new THREE.Vector2(6, -4),
        new THREE.Vector2(-6, -3), new THREE.Vector2(-5, -3), new THREE.Vector2(5, -3), new THREE.Vector2(6, -3),
        new THREE.Vector2(-7, -2), new THREE.Vector2(-6, -2), new THREE.Vector2(6, -2), new THREE.Vector2(7, -2),
        new THREE.Vector2(-7, -1), new THREE.Vector2(-6, -1), new THREE.Vector2(6, -1), new THREE.Vector2(7, -1),
        new THREE.Vector2(-7, 0), new THREE.Vector2(-6, 0), new THREE.Vector2(6, 0), new THREE.Vector2(7, 0),
        new THREE.Vector2(-7, 1), new THREE.Vector2(-6, 1), new THREE.Vector2(6, 1), new THREE.Vector2(7, 1),
        new THREE.Vector2(-7, 2), new THREE.Vector2(-6, 2), new THREE.Vector2(6, 2), new THREE.Vector2(7, 2),
        new THREE.Vector2(-6, 3), new THREE.Vector2(-5, 3), new THREE.Vector2(5, 3), new THREE.Vector2(6, 3),
        new THREE.Vector2(-6, 4), new THREE.Vector2(-5, 4), new THREE.Vector2(-4, 4), new THREE.Vector2(4, 4), new THREE.Vector2(5, 4), new THREE.Vector2(6, 4),
        new THREE.Vector2(-5, 5), new THREE.Vector2(-4, 5), new THREE.Vector2(-3, 5), new THREE.Vector2(3, 5), new THREE.Vector2(4, 5), new THREE.Vector2(5, 5),
        new THREE.Vector2(-4, 6), new THREE.Vector2(-3, 6), new THREE.Vector2(-2, 6), new THREE.Vector2(-1, 6), new THREE.Vector2(0, 6), new THREE.Vector2(1, 6), new THREE.Vector2(2, 6), new THREE.Vector2(3, 6), new THREE.Vector2(4, 6),
        new THREE.Vector2(-2, 7), new THREE.Vector2(-1, 7), new THREE.Vector2(0, 7), new THREE.Vector2(1, 7), new THREE.Vector2(2, 7),
        // fill in array to be 224 in length
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0),
        new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0), new THREE.Vector2(0, 0)
    ];

    /* === FUNCTIONS ========================== */
    function handleShapeChange(index: number): void {
        let neighborhoodShape: THREE.Vector2[] = [];

        // loop through first half of shape array
        for (let i = 0; i < neighborhoodShapes[index].length / 2; i++) {
            if (neighborhoodShapes[index][i]) {
                neighborhoodShape.push(new THREE.Vector2(
                    i % neighborhoodSize - neighborhoodCenter,
                    Math.floor(i / neighborhoodSize) - neighborhoodCenter
                ));
            }
        }

        // loop through second half of shape array
        for (let i = neighboorhoodMiddleIndex; i < neighborhoodShapes[index].length; i++) {
            if (neighborhoodShapes[index][i]) {
                const trueI = i + 1;
                neighborhoodShape.push(new THREE.Vector2(
                    trueI % neighborhoodSize - neighborhoodCenter,
                    Math.floor(trueI / neighborhoodSize) - neighborhoodCenter
                ));
            }
        }

        const shapeLength = neighborhoodShape.length;
        const emptyLength = neighborhoodTotalCells - shapeLength;
        neighborhoodShape = neighborhoodShape.concat(new Array(emptyLength).fill(new THREE.Vector2(0, 0)));

        switch (index) {
            case 0:
                neighborhoodA = neighborhoodShape;
                neighborhoodALength = shapeLength;
                break;
            case 1:
                neighborhoodB = neighborhoodShape;
                neighborhoodBLength = shapeLength;
                break;
            case 2:
                neighborhoodC = neighborhoodShape;
                neighborhoodCLength = shapeLength;
                break;
            case 3:
                neighborhoodD = neighborhoodShape;
                neighborhoodDLength = shapeLength;
                break;
            default:
                break;
        }
    }
</script>



<main>
    <button
        class="rule"
        on:click={controls.showModal}>
        <RuleIcon />
        Rules
    </button>
    <Controls
        {fps}
        bind:neighborhoodStates={neighborhoodStates}
        bind:neighborhoodShapes={neighborhoodShapes}
        bind:this={controls}
        on:shapeChange={e => handleShapeChange(e.detail.index)} />
    <Canvas
        bind:fps={fps}
        {neighborhoodStates}
        {neighborhoodA}
        {neighborhoodALength}
        {neighborhoodB}
        {neighborhoodBLength}
        {neighborhoodC}
        {neighborhoodCLength}
        {neighborhoodD}
        {neighborhoodDLength} />
</main>



<style lang="scss">
    :root {
        // variables
        --MNCA-clr-1000: #FFFFFF;
        --MNCA-clr-600: #a5a5a5;
        --MNCA-clr-red: #FF7557;
        --MNCA-clr-bg: #000000;

        color-scheme: dark;
    }

    :global{
        .icon {
            display: block;

            .stroke {
                fill: none;
                stroke: currentColor;
                stroke-width: 1px;
                stroke-miterlimit: 10;
            }
        }
    }

    main {
        height: 100vh;

        color: var(--MNCA-clr-1000);
        font-family: "JetBrains Mono", monospace;
        font-size: 1rem;
    }

    button.rule {
        display: flex;
        flex-flow: row nowrap;
        align-items: center;
        gap: 6px;
        position: fixed;
        right: 8px;
        bottom: 8px;
        z-index: 1;

        color: var(--MNCA-clr-1000);
        font-weight: 700;
        text-transform: uppercase;
        padding: 8px 13px;
        background-color: var(--MNCA-clr-bg);
    }
</style>