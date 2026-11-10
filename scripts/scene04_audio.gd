extends Node
@export var clarity_filter: AudioEffectLowPassFilter
func _on_accepted_advance() -> void:
	$Advance.play(.12)

func surface_at(_position: Vector2) -> StringName:
	var host=get_parent()
	if host.reveal_busy or host.completed or host.cancelled or host.interaction not in ["medal","bed","lily"]:return &""
	return &"concrete" if host.dream else &"interior"
