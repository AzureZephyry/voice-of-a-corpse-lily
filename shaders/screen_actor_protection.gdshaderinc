// Shared actor alpha, edge and displaced-source protection.
uniform sampler2D actor_atlas : filter_nearest, repeat_disable;
uniform vec4 actor_region = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec4 actor_rect = vec4(0.0);
uniform vec3 actor_inverse_x = vec3(1.0, 0.0, 0.0);
uniform vec3 actor_inverse_y = vec3(0.0, 1.0, 0.0);
uniform vec2 actor_flip = vec2(0.0);
float frame_alpha(vec2 uv) {
    if (any(lessThan(uv, vec2(0.0))) || any(greaterThanEqual(uv, vec2(1.0)))) return 0.0;
    if (actor_flip.x > 0.5) uv.x = 1.0 - uv.x;
    if (actor_flip.y > 0.5) uv.y = 1.0 - uv.y;
    // Explicit native texel centers prevent atlas bleeding into adjacent frames.
    vec2 size = vec2(textureSize(actor_atlas, 0));
    // Fractional feet anchors can put a screen sample exactly on a native texel
    // boundary. Bias only numerical roundoff, never a visible pixel or the actor.
    vec2 frame_pixel = floor(uv * actor_rect.zw + vec2(0.0001)) + vec2(0.5);
    vec2 atlas_uv = actor_region.xy + frame_pixel / size;
    return step(0.001, texture(actor_atlas, atlas_uv).a);
}

float protected_actor(vec2 pixel) {
    vec3 point = vec3(pixel, 1.0);
    vec2 local = vec2(dot(actor_inverse_x, point), dot(actor_inverse_y, point));
    vec2 size = max(actor_rect.zw, vec2(1.0));
    vec2 uv = (local - actor_rect.xy) / size;
    // One screen pixel of conservative edge protection handles subpixel raster
    // rounding. This does not enlarge, redraw, recolor or lift the actual actor.
    vec2 guard = vec2(length(actor_inverse_x.xy), length(actor_inverse_y.xy)) / size;
    if (any(lessThan(uv, -guard)) || any(greaterThanEqual(uv, vec2(1.0) + guard))) return 0.0;
    float alpha = frame_alpha(uv);
    if (alpha > 0.5) return alpha;
    return max(max(frame_alpha(uv + vec2(guard.x, 0.0)), frame_alpha(uv - vec2(guard.x, 0.0))),
        max(frame_alpha(uv + vec2(0.0, guard.y)), frame_alpha(uv - vec2(0.0, guard.y))));
}

// Lighting additionally checks visible color ownership. The glitch deliberately
// retains its original conservative alpha guard. Lighting must not leave a raw,
// bright ring of background grain or ungraded furniture over an occluded actor.
bool actor_color_at(vec2 uv, vec3 visible_color) {
    if (any(lessThan(uv, vec2(0.0))) || any(greaterThanEqual(uv, vec2(1.0)))) return false;
    if (actor_flip.x > 0.5) uv.x = 1.0 - uv.x;
    if (actor_flip.y > 0.5) uv.y = 1.0 - uv.y;
    vec2 pixel = floor(uv * actor_rect.zw + vec2(0.0001)) + vec2(0.5);
    vec4 ink = texture(actor_atlas, actor_region.xy + pixel / vec2(textureSize(actor_atlas, 0)));
    return ink.a > 0.99 && all(lessThan(abs(ink.rgb - visible_color), vec3(0.006)));
}

bool visible_actor_color(vec2 pixel, vec3 color) {
    vec3 point = vec3(pixel, 1.0);
    vec2 local = vec2(dot(actor_inverse_x, point), dot(actor_inverse_y, point));
    vec2 uv = (local - actor_rect.xy) / max(actor_rect.zw, vec2(1.0));
    vec2 guard = vec2(length(actor_inverse_x.xy), length(actor_inverse_y.xy)) / max(actor_rect.zw, vec2(1.0));
    return actor_color_at(uv, color) || actor_color_at(uv + vec2(guard.x, 0.0), color) ||
        actor_color_at(uv - vec2(guard.x, 0.0), color) || actor_color_at(uv + vec2(0.0, guard.y), color) ||
        actor_color_at(uv - vec2(0.0, guard.y), color);
}
