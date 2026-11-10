extends Node
signal presentation_changed(manifested: bool)
## Asset adapter only. RealityPresentation owns all transition state and timing.
const MANIFESTED: Array[Texture2D] = [
	preload("res://assets/environments/hallway/hallway_manifested_background.png"),
	preload("res://assets/environments/hallway/foreground/hallway_manifested_fg_pillar_01.png"),
	preload("res://assets/environments/hallway/foreground/hallway_manifested_fg_pillar_02.png"),
	preload("res://assets/environments/hallway/foreground/hallway_manifested_fg_pillar_03.png"),
	preload("res://assets/environments/hallway/foreground/hallway_manifested_fg_railing.png")
]
const OFFSETS: Array[Vector2] = [Vector2.ZERO, Vector2(839, 0), Vector2(2003, 0), Vector2(3173, 0), Vector2(44, 707)]

@export var visual_paths: Array[NodePath] = []
@export_node_path("Node") var visibility_path: NodePath
@export_node_path("Node") var railing_visibility_path: NodePath
## Optional story cast. The environment laboratory leaves both arrays empty.
@export var actor_paths: Array[NodePath] = []
@export var manifested_frames: Array[SpriteFrames] = []
var _visuals: Array[Sprite2D] = []
var _normal: Array[Dictionary] = []
var _actors: Array[AnimatedSprite2D] = []
var _normal_frames: Array[SpriteFrames] = []
@onready var visibility: Node = get_node(visibility_path)
@onready var railing_visibility: Node = get_node(railing_visibility_path)


func _ready() -> void:
	for path in visual_paths:
		var visual := get_node(path) as Sprite2D
		_visuals.append(visual)
		_normal.append({"texture": visual.texture, "position": visual.position})
	for path in actor_paths:
		var actor := get_node(path) as AnimatedSprite2D
		_actors.append(actor)
		_normal_frames.append(actor.sprite_frames)


func can_present_manifested() -> bool:
	return _visuals.size() == MANIFESTED.size() and _actors.size() == manifested_frames.size()


func present_manifested() -> void:
	for i in _visuals.size():
		_visuals[i].texture = MANIFESTED[i]
		_visuals[i].position = OFFSETS[i]
	visibility.refresh_foregrounds()
	railing_visibility.set_active(true)
	for i in _actors.size():
		_swap_actor(_actors[i], manifested_frames[i])
	presentation_changed.emit(true)


func present_normal() -> void:
	for i in _visuals.size():
		_visuals[i].texture = _normal[i].texture
		_visuals[i].position = _normal[i].position
	visibility.refresh_foregrounds()
	railing_visibility.set_active(false)
	for i in _actors.size():
		_swap_actor(_actors[i], _normal_frames[i])
	presentation_changed.emit(false)


func _swap_actor(actor: AnimatedSprite2D, frames: SpriteFrames) -> void:
	var animation := actor.animation
	var frame := actor.frame
	var progress := actor.frame_progress
	var playing := actor.is_playing()
	actor.sprite_frames = frames
	actor.animation = animation
	actor.set_frame_and_progress(frame, progress)
	if playing: actor.play()
	else: actor.pause()
