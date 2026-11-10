extends "res://scripts/player_movement.gd"
## Story-local control ownership; shared player behavior remains unchanged.
var control_locked: bool = true
var scripted_direction := Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not control_locked:
		super._physics_process(delta)
		return
	velocity = scripted_direction.limit_length(1.0) * SPEED
	var before := global_position
	move_and_slide()
	animated_sprite.update_motion(scripted_direction, global_position - before)


func set_control(locked: bool, direction := Vector2.ZERO) -> void:
	control_locked = locked
	scripted_direction = direction
	velocity = Vector2.ZERO
	set_physics_process(true)
	animated_sprite.update_motion(direction, Vector2.ZERO)
