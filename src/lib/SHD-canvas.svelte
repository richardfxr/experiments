<script lang="ts">
    /* === IMPORTS ============================ */
    import { onMount } from 'svelte';
    import * as THREE from 'three';

    /* === THREE ============================== */
    let renderer: THREE.WebGLRenderer;
    let camera: THREE.OrthographicCamera;
    let scene: THREE.Scene;
    let plane: THREE.PlaneGeometry;
    const uniforms = {
		iTime: { value: 0 },
		iResolution: { value: new THREE.Vector3() },
	};
    const fragmentShader = `
        #include <common>

        uniform vec3 iResolution;
        uniform float iTime;

        //https://iquilezles.org/articles/palettes/
        vec3 palette( float t ) {
            vec3 a = vec3(0.5, 0.5, 0.5);
            vec3 b = vec3(0.5, 0.5, 0.5);
            vec3 c = vec3(1.0, 1.0, 1.0);
            vec3 d = vec3(0.263,0.416,0.557);

            return a + b*cos( 6.28318*(c*t+d) );
        }

        //https://www.shadertoy.com/view/mtyGWy
        void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
            vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
            vec2 uv0 = uv;
            vec3 finalColor = vec3(0.0);
            
            for (float i = 0.0; i < 4.0; i++) {
                uv = fract(uv * 1.5) - 0.5;

                float d = length(uv) * exp(-length(uv0));

                vec3 col = palette(length(uv0) + i*.4 + iTime*.4);

                d = sin(d*8. + iTime)/8.;
                d = abs(d);

                d = pow(0.01 / d, 1.2);

                finalColor += col * d;
            }
                
            fragColor = vec4(finalColor, 1.0);
        }

        void main() {
            mainImage(gl_FragColor, gl_FragCoord.xy);
        }
    `;

    /* === BINDINGS =========================== */
    let canvas: HTMLCanvasElement;

    /**
     * Three.js render function that is called each frame
     */
    function render(time: any): void {
        time *= 0.001; // convert to seconds

        uniforms.iResolution.value.set(canvas.width, canvas.height, 1);
		uniforms.iTime.value = time;
        
        renderer.render(scene, camera);
        requestAnimationFrame(render);
    }

    /**
     * Resize renderer to canvas size on window resize.
     */
    function resizeRenderer(): void {
        renderer.setSize(
            canvas.clientWidth,
            canvas.clientHeight,
            false
        );
    }

    /* === LIFECYCLE ========================== */
    onMount(() => {
		renderer = new THREE.WebGLRenderer({
            antialias: true,
            canvas
        });
        renderer.autoClearColor = false;
        
        camera = new THREE.OrthographicCamera(
            - 1, // left
            1, // right
            1, // top
            - 1, // bottom
            - 1, // near,
            1, // far
        );

        scene = new THREE.Scene();
        plane = new THREE.PlaneGeometry(2, 2);
        const material = new THREE.ShaderMaterial({
            fragmentShader,
            uniforms,
        });
        scene.add(new THREE.Mesh(plane, material));

        requestAnimationFrame(render);
	});
</script>



<svelte:window on:resize={resizeRenderer}/>

<canvas id="canvas" bind:this={canvas}></canvas>