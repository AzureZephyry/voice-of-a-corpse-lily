shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;
uniform bool actor = false;
uniform vec2 foot;
uniform vec2 half_footprint;
void fragment() {
    vec2 p=SCREEN_UV*vec2(1280.0,960.0)-foot;
    // Exclude only this caster's own footprint, not other casters behind it.
    if (!actor && all(lessThanEqual(abs(p),half_footprint))) { discard; }
    float coverage=actor ? texture(TEXTURE,UV).a : 1.0;
    COLOR=vec4(coverage*0.85,0.0,0.0,0.0);
}
