extends Node2D
## Fixed, editor-authored population. Only nearby agents use physics/animation.
@export var actor_material: ShaderMaterial
@export_range(100.0, 400.0, 20.0) var camera_margin: float = 220.0
@export var enabled: bool = true
@onready var player: CharacterBody2D = get_node("../Player")
@onready var camera: Camera2D = get_node("../Camera2D")
var actors: Array = []
var active_count: int = 0
var _coarse_elapsed: float = 0.0
var _empty: Array = []

func _ready() -> void:
	actors = get_children()
	for actor in actors:
		# Normalize nested-scene localization to one material per crowd instance.
		actor.animated_sprite.material = actor_material
		actor.visible = enabled

func _physics_process(delta: float) -> void:
	active_count = 0
	_coarse_elapsed += delta
	var coarse_tick: bool = _coarse_elapsed >= .3
	var half_width: float = get_viewport_rect().size.x * .5 / camera.zoom.x
	for actor in actors:
		if actor.visible != enabled: actor.visible = enabled
		if not enabled:
			actor.animated_sprite.pause()
			continue
		var near: bool = absf(actor.global_position.x-camera.global_position.x) < half_width + camera_margin
		if near:
			active_count += 1
			actor.tick(delta, true, player, actors)
		elif coarse_tick:
			actor.tick(_coarse_elapsed, false, null, _empty)
	if coarse_tick: _coarse_elapsed = 0.0
