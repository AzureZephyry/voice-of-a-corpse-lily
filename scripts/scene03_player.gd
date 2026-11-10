extends "res://scripts/hallway_story_player.gd"
## Match the 1x Classroom/Hallway's 150 screen-pixel traversal at Exterior zoom2.
var road_active: bool=false
func _physics_process(_delta: float) -> void:
	var direction: Vector2=scripted_direction if control_locked else Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var camera: Camera2D=get_viewport().get_camera_2d()
	var zoom: float=camera.zoom.x if camera!=null else 1.0
	velocity=direction.limit_length(1.0)*SPEED/zoom
	var before:=global_position
	move_and_slide()
	animated_sprite.update_motion(direction,global_position-before)
