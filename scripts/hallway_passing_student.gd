extends "res://scripts/npc_character.gd"
## One deterministic pass, no respawn, scheduling or autonomous pathfinding.
@export var end_x: float = 3000.0


func _ready() -> void:
	set_move_direction(Vector2(signf(end_x - position.x), 0))


func _physics_process(delta: float) -> void:
	if absf(end_x - position.x) < 3.0:
		set_move_direction(Vector2.ZERO)
		$CollisionShape2D.set_deferred("disabled", true)
		hide()
		set_physics_process(false)
		return
	super._physics_process(delta)
