shader_type canvas_item;
render_mode unshaded;
#include "res://shaders/hallway_time_grade.gdshaderinc"
uniform sampler2D hallway_shadow_mask : filter_nearest, repeat_disable;
uniform bool contacts_enabled = true;
uniform float contact_opacity = 0.22;
uniform float manifested_contact_opacity = 0.16;
uniform vec4 door_windows[6];
uniform vec4 thin_windows[6];
uniform float window_spill_energy = 0.0;
uniform float window_glass_energy = 0.0;

vec2 opening_spill(vec2 p, vec4 opening, vec2 radius) {
	vec2 center = opening.xy + vec2(opening.z * 0.5, opening.w + 10.0);
	vec2 delta = (p - center) / radius;
	if (abs(delta.x) > 1.7 || p.y < opening.y-16.0 || p.y > 520.0) { return vec2(0.0); }
	float soft_fill = exp2(-3.0 * dot(delta, delta)) * smoothstep(opening.y-16.0,opening.y+8.0,p.y);
	// A weaker, aligned reflection reaches the real y350 wall/floor junction.
	// It joins the wall spill rather than drawing a hard beam through the door.
	vec2 floor_delta = (p - vec2(center.x,375.0)) / vec2(radius.x*0.85,85.0);
	float coupling = opening.w > 20.0 ? 0.50 : 0.30;
	float floor_fill = exp2(-3.0*dot(floor_delta,floor_delta))*smoothstep(340.0,365.0,p.y)*coupling;
	soft_fill = max(soft_fill,floor_fill);
	vec2 edge = min(p - opening.xy, opening.xy + opening.zw - p);
	float glass = smoothstep(0.0,2.0,min(edge.x,edge.y));
	return vec2(soft_fill,glass);
}

void vertex() {
	hallway_world_y = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).y;
}

void fragment() {
	vec2 world = UV * vec2(3842.0, 960.0);
	// The source's rear wall/door bottoms end at y350. Stair risers are entirely
	// above that boundary; rail and pillars are separate, nonreceiving sprites.
	bool ground = world.x >= 44.0 && world.x < 3842.0 && world.y >= 350.0 && world.y < 954.0;
	vec2 coverage = ground ? clamp(texture(hallway_shadow_mask, UV).rg, vec2(0.0), vec2(1.0)) : vec2(0.0);
	vec3 original = COLOR.rgb;
	COLOR.rgb = hallway_lit(original, coverage.r);
	if (window_spill_energy+window_glass_energy > 0.00001 && !manifested && world.y < 520.0) {
		vec2 presence = vec2(0.0);
		for (int i=0;i<6;i++) {
			vec2 door = opening_spill(world,door_windows[i],vec2(85.0,125.0));
			vec2 transom = opening_spill(world,thin_windows[i],vec2(150.0,130.0));
			presence = max(presence,max(door,transom*vec2(0.72,1.35)));
		}
		// Separate bounded glass luminance from diffuse spill: multiplying nearly
		// black authored glass alone cannot communicate a lit opening. Frames stay intact.
		vec3 borrowed = mix(time_tint.rgb,vec3(1.0,0.95,0.86),0.25);
		COLOR.rgb += borrowed * (window_spill_energy * original * presence.x + vec3(window_glass_energy * presence.y));
	}
	float contact = manifested ? manifested_contact_opacity : contact_opacity;
	COLOR.rgb *= 1.0 - coverage.g * (contacts_enabled ? contact : 0.0);
}
