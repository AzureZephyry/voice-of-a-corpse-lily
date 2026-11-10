shader_type canvas_item;
render_mode unshaded, blend_disabled;

// Captured AFTER world lighting, BEFORE story/HUD canvases. No new world viewport.
uniform sampler2D world_image : hint_screen_texture, filter_nearest, repeat_disable;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float horizontal_pixels = 18.0;
uniform float vertical_pixels = 2.0;
uniform float band_height = 8.0;
uniform float fragment_width = 64.0;
uniform float pattern_seed = 113.0;
uniform float direction = 1.0;
uniform bool reduced_motion = false;

// Protect the actual animated alpha silhouette, including mirrored/offset frames.
// Source-sample protection also prevents displaced copies of Albert elsewhere.
#include "res://shaders/screen_actor_protection.gdshaderinc"
uniform vec4 hud_rect = vec4(0.0);

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7)) + pattern_seed) * 43758.5453);
}

void fragment() {
    vec2 pixel = SCREEN_UV / SCREEN_PIXEL_SIZE;
    vec4 original = textureLod(world_image, SCREEN_UV, 0.0);
    bool under_hud = all(greaterThanEqual(pixel, hud_rect.xy)) && all(lessThan(pixel, hud_rect.xy + hud_rect.zw));
    if (protected_actor(pixel) > 0.5 || under_hud) {
        COLOR = original;
    } else if (reduced_motion) {
        // Accessibility: a short world-only dim/resolve; no motion, noise or bands.
        float cover = smoothstep(0.0, 0.48, progress) * (1.0 - smoothstep(0.52, 1.0, progress));
        COLOR = vec4(mix(original.rgb, vec3(0.018), cover), original.a);
    } else {
        float rise = smoothstep(0.0, 0.30, progress);
        float settle = 1.0 - smoothstep(0.66, 1.0, progress);
        float envelope = rise * settle;
        float peak = 1.0 - abs(progress * 2.0 - 1.0);
        float tick = floor(progress * 17.0);
        float band = floor(pixel.y / max(band_height, 1.0));
        vec2 cell = vec2(floor(pixel.x / max(fragment_width, 1.0)), band);
        float broken = step(0.67, hash(vec2(band, tick)));
        float fragment = step(0.78, hash(cell + vec2(tick, 3.0)));
        float jitter = (hash(vec2(tick, 61.0)) - 0.5) * 2.0;
        float shift = (hash(vec2(band, tick + 13.0)) - 0.5) * 2.0;
        vec2 offset = vec2(
            round(horizontal_pixels * envelope * (0.10 * jitter + (0.22 + 0.78 * peak) * shift * max(broken, fragment))),
            round(vertical_pixels * envelope * (hash(cell + tick) - 0.5) * 2.0 * fragment)
        ) * direction;
        // Never sample Albert into a displaced environmental band.
        if (protected_actor(pixel + offset) > 0.5) offset = vec2(0.0);
        vec2 sample_uv = clamp(SCREEN_UV + offset * SCREEN_PIXEL_SIZE, SCREEN_PIXEL_SIZE * 0.5, vec2(1.0) - SCREEN_PIXEL_SIZE * 0.5);
        vec3 displaced = textureLod(world_image, sample_uv, 0.0).rgb;
        // Irregular shutters collapse the image, rather than fading its whole opacity.
        // Full coverage at 0.5 conceals the authority's swap on both rendered sides.
        float cover = smoothstep(0.28, 0.44, progress) * (1.0 - smoothstep(0.57, 0.80, progress));
        float shutter = step(hash(cell + vec2(19.0, 7.0)), cover) * step(0.001, cover);
        vec3 ink = vec3(0.012, 0.014, 0.019) + vec3(hash(cell + tick) * 0.014);
        // Brief low-contrast broken bands, not continuous TV static or bright flashes.
        displaced *= 1.0 - 0.12 * envelope * broken;
        COLOR = vec4(mix(displaced, ink, shutter), original.a);
    }
}
