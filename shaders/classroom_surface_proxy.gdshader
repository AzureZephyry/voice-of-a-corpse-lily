shader_type canvas_item;
render_mode unshaded, blend_disabled;
uniform bool textured = true;
uniform float foot_y;
uniform float top_height = 0.0;
uniform float kind = 1.0; // 1 front, 2 top, 3 actor, 4 side, 5 rear-wall bounce
uniform float top_edge = -1.0;
void fragment() {
    vec4 source=texture(TEXTURE,UV);
    vec3 c=source.rgb*255.0;
    bool floor_color=all(lessThan(abs(c-vec3(164,178,179)),vec3(0.6))) || all(lessThan(abs(c-vec3(132,142,143)),vec3(0.6)));
    if (textured && (source.a<0.5 || floor_color)) { discard; }
    vec2 p=SCREEN_UV*vec2(1280.0,960.0);
    float mode=kind;
    if (top_edge>=0.0 && p.y<top_edge) { mode=2.0; }
    float height=mode==2.0 ? top_height : clamp((foot_y-p.y)*0.65,0.0,150.0);
    float ground_y=mode==2.0 ? p.y+top_height : foot_y;
    COLOR=vec4(p.x/1280.0,ground_y/960.0,height/200.0,mode/8.0);
}
