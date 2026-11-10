extends "res://scripts/overworld_interaction.gd"
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not dialogue_open:
		if not is_instance_valid(_selected) or not _selected.available(): return
	super._unhandled_key_input(event)
