shader_type sky;
render_mode disable_fog;

// The renderer supplies game-clock minutes and normalized lighting/weather factors.
// There is deliberately no TIME uniform: sky motion follows simulation time.
uniform float clock_minutes = 720.0;
uniform float daylight = 1.0;
uniform float twilight = 0.0;
uniform float overcast = 0.0;

float hash(vec2 sample_position) {
    return fract(sin(dot(sample_position, vec2(127.1, 311.7))) * 43758.5453);
}

// Smoothly interpolate deterministic values at the four surrounding lattice points.
float noise(vec2 sample_position) {
    vec2 cell_origin = floor(sample_position);
    vec2 interpolation = fract(sample_position);
    interpolation = interpolation * interpolation * (3.0 - 2.0 * interpolation);
    return mix(
        mix(hash(cell_origin), hash(cell_origin + vec2(1, 0)), interpolation.x),
        mix(hash(cell_origin + vec2(0, 1)), hash(cell_origin + vec2(1, 1)), interpolation.x),
        interpolation.y
    );
}

void sky() {
    float horizon_height = clamp(EYEDIR.y, 0.0, 1.0);
    vec3 zenith_color = mix(vec3(0.008, 0.015, 0.045), vec3(0.12, 0.38, 0.68), daylight);
    vec3 horizon_color = mix(vec3(0.035, 0.055, 0.10), vec3(0.68, 0.79, 0.85), daylight);
    horizon_color = mix(horizon_color, vec3(0.76, 0.35, 0.18), twilight * 0.7);
    vec3 sky_color = mix(horizon_color, zenith_color, pow(horizon_height, 0.45));

    // Sparse star points fade out as daylight rises and near the horizon.
    vec2 star_grid = SKY_COORDS * vec2(900.0, 450.0);
    float star_brightness = step(0.994, hash(floor(star_grid)))
        * (1.0 - smoothstep(0.06, 0.34, length(fract(star_grid) - 0.5)));
    sky_color += vec3(0.75, 0.85, 1.0) * star_brightness * (1.0 - daylight)
        * smoothstep(0.02, 0.15, horizon_height);

    // Four noise scales produce cloud detail without external texture assets.
    vec2 cloud_position = EYEDIR.xz / max(0.15, horizon_height) * 1.3
        + vec2(clock_minutes * 0.002, clock_minutes * 0.0006);
    float cloud_noise = noise(cloud_position) * 0.55 + noise(cloud_position * 2.03) * 0.27
        + noise(cloud_position * 4.07) * 0.13 + noise(cloud_position * 8.1) * 0.05;
    float cloud_cover = smoothstep(0.48, 0.72, cloud_noise) * smoothstep(0.0, 0.12, horizon_height);
    vec3 cloud_color = mix(vec3(0.07, 0.09, 0.14), vec3(0.91, 0.91, 0.87), daylight);
    sky_color = mix(sky_color, cloud_color, cloud_cover * 0.85);

    float sun_angle = (clock_minutes / 1440.0 - 0.25) * TAU;
    vec3 sun_direction = normalize(vec3(cos(sun_angle), sin(sun_angle), 0.3));
    float sun_disc = smoothstep(0.9993, 0.9997, dot(EYEDIR, sun_direction));
    sky_color += sun_disc * vec3(1.0, 0.85, 0.55) * daylight;

    // Overcast obscures stars and the sun as well as the clear-sky gradient.
    sky_color = mix(sky_color,
        mix(vec3(0.035, 0.045, 0.065), vec3(0.28, 0.33, 0.38), daylight)
            * (0.8 + cloud_noise * 0.3), overcast * 0.95);
    COLOR = sky_color;
}
