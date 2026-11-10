extends "res://scripts/hallway_normal_playable.gd"
## Partial Scene 02 boundary. The deferred walkway/bench has not completed.
signal hallway_segment_completed
var segment_announced: bool = false


func _on_hallway_segment_completed() -> void:
	if segment_announced: return
	segment_announced = true
	hallway_segment_completed.emit()
