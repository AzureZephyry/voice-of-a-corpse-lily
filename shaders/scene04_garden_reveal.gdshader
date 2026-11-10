shader_type canvas_item;
render_mode unshaded;
uniform float progress : hint_range(0.0,1.0) = 0.0;
uniform bool reduced_motion = false;
uniform float breath=0.0;
void fragment() {
 vec2 sample_uv=UV;
 float lily=1.0-smoothstep(.055,.09,length(UV-vec2(.5)));
 sample_uv=vec2(.5)+(UV-vec2(.5))/(1.0+breath*lily);
	vec4 art = texture(TEXTURE, sample_uv);
	float edge = max(abs(UV.x-0.5), abs(UV.y-0.5))*2.0;
	float reveal = smoothstep(1.0-progress-0.04,1.0-progress+0.04,edge);
	if (progress <= 0.0) reveal=0.0;
	if (progress >= 1.0) reveal=1.0;
	COLOR=vec4(art.rgb,art.a*(reduced_motion ? progress : reveal));
}
