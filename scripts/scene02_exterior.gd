extends "res://scripts/scene03_story.gd"
signal exterior_segment_completed
var segment_announced: bool = false

func _on_segment_finished() -> void:
	if segment_announced: return
	segment_announced = true
	exterior_segment_completed.emit()
	if get_tree().current_scene==self:
		await get_tree().create_timer(.65,false).timeout
		begin_guardhouse()
