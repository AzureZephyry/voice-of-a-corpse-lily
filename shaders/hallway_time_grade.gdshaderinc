uniform vec4 time_tint : source_color = vec4(1.0);
uniform float time_energy = 1.0;
uniform float time_weight = 0.0;
uniform float cover_depth = 0.12;
uniform bool manifested = false;
uniform bool time_enabled = true;
uniform float ambient_energy = 0.34;
uniform float diffuse_energy = 0.0;
uniform float direct_energy = 0.0;
varying float hallway_world_y;

vec3 hallway_lit(vec3 art, float cast_coverage) {
	float open_edge = smoothstep(350.0, 900.0, hallway_world_y);
	float diffuse = diffuse_energy * mix(0.30, 1.0, open_edge);
	float direct = direct_energy * mix(0.10, 1.0, open_edge);
	float visibility = 1.0 - clamp(cast_coverage, 0.0, 1.0) * 0.92;
	vec3 light = vec3(ambient_energy) + time_tint.rgb * (diffuse + direct * visibility);
	return mix(art, art * min(light, vec3(1.02)), manifested || !time_enabled ? 0.0 : time_weight);
}

vec3 hallway_grade(vec3 art) {
	return hallway_lit(art, 0.0);
}
