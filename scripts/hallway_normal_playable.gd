extends Node2D
## Standalone environment test. Spawn and bounds do not define screenplay entry/exit.

@export var camera_height: float = 480.0
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	_update_camera()
	get_node("/root/AudioDirector").ensure_gameplay_music()


func _physics_process(_delta: float) -> void:
	_update_camera()


func _update_camera() -> void:
	var half_width: float = camera.get_viewport_rect().size.x / (2.0 * camera.zoom.x)
	var left: float = camera.limit_left + half_width
	var right: float = camera.limit_right - half_width
	camera.global_position = Vector2(roundf(clampf(player.global_position.x, left, right)), camera_height)
