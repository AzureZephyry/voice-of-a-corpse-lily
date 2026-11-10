extends "res://scripts/classroom_psych_presentation.gd"
## Reuse fracture/echo choreography; only authored Hallway profiles differ.
const HALLWAY_PROFILES: Dictionary = {
	&"pair4_heard": [0, ["IDIOT"], 1],
	&"pair5_heard_one": [0, ["ALONE", "NEEDS HELP"], 2],
	&"pair6_heard_one": [2, ["THE GUIDE", "COUNTING ME", "SUPPOSED TO BE ME", "FAIL TOGETHER"], 4],
}
var _major_segment: bool = false

## Walking pulses have no dialogue panel or new spoken/echo text. Consume their
## existing lifecycle without drawing a phantom panel fracture over free movement.
func _on_transition_started(from: int, toward: int, cue: StringName) -> void:
	if String(cue).begins_with("hallway_walk_"):
		_restore_panel()
		_clear_fragments()
		fracture.hide()
		_waiting = false
		_vibrating = false
		switch_count += 1
		set_process(false)
		return
	super._on_transition_started(from,toward,cue)

func _on_transition_finished(target: int, cue: StringName) -> void:
	if String(cue).begins_with("hallway_walk_"): return
	super._on_transition_finished(target,cue)


func _ready() -> void:
	super._ready()
	# Warm only the authored echo glyphs/sizes before dialogue starts. Otherwise
	# first-use rasterization can stall the uncovered Manifested frame.
	var server := TextServerManager.get_primary_interface()
	for profile: Array in HALLWAY_PROFILES.values():
		for i in int(profile[2]):
			var fragment: Control = fragments[i]
			var word: String = profile[1][i % profile[1].size()]
			fragment.configure(word, 68 + int(profile[0]) * 14 + (14 if i % 4 == 0 else (-10 if i % 4 == 3 else 0)), profile[0], i * 11 + int(profile[0]) * 7)
			for font: Font in [fragment.font, fragment.heavier_font]:
				for rid: RID in font.get_rids():
					for glyph in word:
						server.font_render_range(rid, Vector2i(fragment.font_size, 0), glyph.unicode_at(0), glyph.unicode_at(0))


func has_profile(event: StringName) -> bool:
	return HALLWAY_PROFILES.has(event)


func profile_for(event: StringName) -> Array:
	return HALLWAY_PROFILES[event]


func is_major_event(cue: StringName, from: int) -> bool:
	if from == 0:
		_major_segment = _event_for(cue) == &"pair6_heard_one"
	return _major_segment
