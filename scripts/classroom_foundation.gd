extends Node2D
## Normal classroom foundation. Movement is opt-in in the separate preview scene.

const AlbertAnimation = preload("res://scripts/albert_animation.gd")

@export var development_preview: bool = false

@onready var player: CharacterBody2D = $Player
@onready var animation: AlbertAnimation = $Player/AnimatedSprite2D


func _ready() -> void:
	# The inherited movement and directional animation scripts remain unchanged.
	player.velocity = Vector2.ZERO
	player.set_physics_process(development_preview)
	animation.facing_sector = 0
	animation.show_idle()
