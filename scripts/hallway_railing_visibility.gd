extends Node
## Local raised-rail readability; the rest of the authored rail stays opaque.
const ActorMask = preload("res://scripts/screen_actor_mask.gd")
@export_node_path("AnimatedSprite2D") var actor_path: NodePath
@export_node_path("Sprite2D") var railing_path: NodePath
@export var overlap_material: ShaderMaterial
@onready var actor: AnimatedSprite2D = get_node(actor_path)
@onready var railing: Sprite2D = get_node(railing_path)
var _original: Material


func _ready() -> void:
	_original = railing.material
	set_process(false)


func set_active(active: bool) -> void:
	set_process(active)
	if active:
		_update_mask()
		railing.material = overlap_material
	else:
		railing.material = _original


func _process(_delta: float) -> void:
	_update_mask()


func _update_mask() -> void:
	overlap_material.set_shader_parameter("actor_visible", actor.is_visible_in_tree())
	ActorMask.apply(overlap_material, actor)


func _exit_tree() -> void:
	if is_instance_valid(railing):
		railing.material = _original
