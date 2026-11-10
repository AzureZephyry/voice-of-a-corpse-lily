extends "res://scripts/audio/school_exterior_audio.gd"
## Existing approved outdoor bed; missing authored cues remain unassigned hooks.
signal production_cue_requested(cue: StringName)
var missing_cues: Array[StringName] = []
var advance_count: int = 0
var _quiet: bool = false
var _music_bus_before: float
var _ending_mix: Tween

func _ready() -> void:
	_music_bus_before = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	super._ready()

func _refresh() -> void:
	super._refresh()
	if _quiet: AudioDirector.fade_ambience(-3.0, 1.8)

func _on_accepted_advance() -> void:
	advance_count += 1
	$Advance.play(0.12)

func _on_stage(id: StringName, _direction: String) -> void:
	if id == &"walkway_sound":
		_quiet = true
		_refresh()
	elif id in [&"phone_in_pocket", &"final_music_hold"]:
		missing_cues.append(id)
		production_cue_requested.emit(id)
		if id == &"final_music_hold":
			_ending_mix = create_tween()
			_ending_mix.tween_method(func(db): AudioDirector.set_bus_level(&"Music", db), _music_bus_before, maxf(-60.0, _music_bus_before - 3.0), 1.8)

func cancel_presentation() -> void:
	if is_instance_valid(_ending_mix): _ending_mix.kill()
	AudioDirector.set_bus_level(&"Music", _music_bus_before)

func _exit_tree() -> void:
	cancel_presentation()
	super._exit_tree()
