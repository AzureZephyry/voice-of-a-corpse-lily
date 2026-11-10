shader_type canvas_item;
render_mode unshaded;
uniform float damage = 0.2;
uniform float pattern_seed = 7.0;
uniform float burst = 0.0;
uniform int protected_count = 0;
uniform vec4 protected_rects[12];
void fragment() {
    vec4 ink = texture(TEXTURE, UV) * COLOR;
    // Static narrow breaks in the existing glyph ink, never flashing/static noise.
    float row = floor(FRAGCOORD.y / 2.0) + floor(burst*5.0);
    float selected = step(0.73, fract(sin(row * 17.13 + pattern_seed) * 43758.54));
    float chunk = step(0.48, fract(sin(floor(FRAGCOORD.x / 9.0) * 11.37 + row) * 2417.13));
    ink.a *= 1.0 - selected * chunk * min(1.0,damage+burst*0.35);
    for (int i=0;i<protected_count;i++) {
        vec4 r=protected_rects[i];
        if (all(greaterThanEqual(FRAGCOORD.xy,r.xy)) && all(lessThan(FRAGCOORD.xy,r.xy+r.zw))) ink.a=0.0;
    }
    COLOR = ink;
}
