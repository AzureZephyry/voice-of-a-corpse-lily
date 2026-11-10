shader_type canvas_item;

// A brief text-only displacement. No flashing, camera motion or world effects.
uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform float effect_time = 0.0;

void vertex() {
	float band = floor(VERTEX.y / 5.0);
	VERTEX.x += round(floor(sin(band * 1.7 + effect_time * 22.0) * 2.0) * amount);
}
