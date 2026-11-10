shader_type canvas_item;
render_mode unshaded;
#include "res://shaders/hallway_time_grade.gdshaderinc"

void vertex() {
	hallway_world_y = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).y;
}

void fragment() {
	COLOR.rgb = hallway_grade(COLOR.rgb);
}
