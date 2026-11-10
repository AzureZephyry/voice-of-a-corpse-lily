shader_type canvas_item;
render_mode unshaded;
#include "res://shaders/screen_actor_protection.gdshaderinc"
#include "res://shaders/hallway_time_grade.gdshaderinc"
uniform float overlap_opacity : hint_range(0.0, 1.0) = 0.38;
uniform bool actor_visible = true;

void vertex() {
	hallway_world_y = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).y;
}

void fragment() {
	vec4 art = COLOR;
	art.rgb = hallway_grade(art.rgb);
	float overlap = actor_visible ? protected_actor(SCREEN_UV / SCREEN_PIXEL_SIZE) : 0.0;
	art.a *= mix(1.0, overlap_opacity, overlap);
	COLOR = art;
}
