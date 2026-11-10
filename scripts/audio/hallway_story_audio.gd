extends Node
## Missing atmosphere remains an explicit production hook, never substitute audio.
signal atmosphere_requested(cue_id: StringName)
var advance_count: int = 0
var missing_cues: Array[StringName] = []


func _on_accepted_advance() -> void:
	advance_count += 1
	$Advance.play(0.12)


func _on_stage_direction(id: StringName, _direction: String) -> void:
	if id in [&"hallway_sound", &"shared_laughter", &"walk_past"]:
		missing_cues.append(id)
		atmosphere_requested.emit(id)
