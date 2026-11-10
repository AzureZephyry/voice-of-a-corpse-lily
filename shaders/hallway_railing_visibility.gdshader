shader_type canvas_item;
render_mode unshaded;

// Only the raised Manifested rail, only over Albert's current alpha silhouette.
#include "res://shaders/screen_actor_protection.gdshaderinc"
uniform float overlap_opacity : hint_range(0.0, 1.0) = 0.38;
uniform bool actor_visible = true;

void fragment() {
	vec4 art = COLOR;
	float overlap = actor_visible ? protected_actor(SCREEN_UV / SCREEN_PIXEL_SIZE) : 0.0;
	art.a *= mix(1.0, overlap_opacity, overlap);
	COLOR = art;
}
