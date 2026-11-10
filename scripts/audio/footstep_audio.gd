extends Node
## Fallback: movement-gated original walking sequences, not claimed contact-frame cues.
## Seek past the measured quiet lead-in; one voice, short start/stop fades, no overlaps.

const RECORDINGS = {
	&"interior": preload("res://assets/audio/footsteps/walking_concrete_interior.wav"),
	&"concrete": preload("res://assets/audio/footsteps/walking_concrete.wav"),
	&"grass": preload("res://assets/audio/footsteps/walking_grass.wav"),
}
const GAINS = {&"interior": -8.0, &"concrete": -4.0, &"grass": -14.0}
const STARTS = {&"interior": 0.45, &"concrete": 0.12, &"grass": 0.03}
@export var movement_driven_externally: bool=false
@export_enum("none", "interior", "concrete", "grass") var default_surface: String = "none"
@export_node_path("Node") var surface_provider: NodePath
@onready var player: CharacterBody2D = get_parent()
@onready var voice: AudioStreamPlayer = $Voice
var surface: StringName = &""
var actual_motion: bool = false
var starts: int = 0
var _last_position: Vector2
var _recycling: bool = false
var _provider: Node

func _ready() -> void:
	process_physics_priority = 10
	_last_position = player.global_position
	if not surface_provider.is_empty():
		_provider = get_node(surface_provider)

func _physics_process(delta: float) -> void:
	var distance: float = player.global_position.distance_to(_last_position)
	_last_position = player.global_position
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	actual_motion = (player.is_physics_processing() or movement_driven_externally) and distance > 0.02 and String(sprite.animation).begins_with("walk_")
	var desired: StringName = StringName(default_surface)
	if is_instance_valid(_provider):
		desired = _provider.surface_at(player.global_position)
	if not RECORDINGS.has(desired):
		desired = &""
	if voice.playing and voice.get_playback_position() >= voice.stream.get_length() - 0.12:
		_recycling = true
	var sounding: bool = actual_motion and not desired.is_empty()
	if sounding and not voice.playing:
		surface = desired
		voice.stream = RECORDINGS[surface]
		voice.volume_linear = 0.0
		voice.play(STARTS[surface])
		starts += 1
		_recycling = false
	var target: float = db_to_linear(GAINS.get(surface, -80.0)) if sounding and desired == surface and not _recycling else 0.0
	voice.volume_linear = move_toward(voice.volume_linear, target, db_to_linear(GAINS.get(surface, -80.0)) * delta / 0.06)
	if voice.playing and target == 0.0 and voice.volume_linear <= 0.00001:
		voice.stop()
