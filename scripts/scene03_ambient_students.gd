extends Node2D
## Fixed outdoor population: existing waypoint roaming, characters and shadow receiver.
@export var manifested_frames: Array[SpriteFrames]=[]
var actors: Array[CharacterBody2D]=[]
var normal_frames: Array[SpriteFrames]=[]
var manifested: bool=false

func _ready() -> void:
	for child in get_children():
		if child is CharacterBody2D:
			actors.append(child)
			normal_frames.append(child.animated_sprite.sprite_frames)
			child.face_direction(Vector2.RIGHT if actors.size()%2==0 else Vector2.DOWN)

func set_manifested(value: bool) -> void:
	if manifested==value: return
	manifested=value
	for i in actors.size():
		var sprite: AnimatedSprite2D=actors[i].animated_sprite
		var animation: StringName=sprite.animation
		var frame: int=sprite.frame
		var progress: float=sprite.frame_progress
		var playing: bool=sprite.is_playing()
		sprite.sprite_frames=manifested_frames[i] if value else normal_frames[i]
		sprite.animation=animation
		sprite.set_frame_and_progress(frame,progress)
		if playing: sprite.play()

var _visibility_elapsed: float=0.0
func _process(delta: float) -> void:
	_visibility_elapsed+=delta
	if _visibility_elapsed<.15: return
	_visibility_elapsed=0.0
	var screen: Rect2=get_viewport_rect().grow(128)
	for actor in actors:
		var near: bool=screen.has_point(actor.get_global_transform_with_canvas().origin)
		actor.animated_sprite.speed_scale=1.0 if near else 0.0
		var shadow: Node=actor.get_node("ActorShadow2D")
		if not is_instance_valid(shadow.receiver): continue
		if shadow.is_processing()!=near:
			shadow.set_process(near)
			shadow.mask_visual.visible=near
			shadow.receiver.request_actor_shadow_redraw()

# Mask visuals live in the receiver viewport, so carry them with their actors.
func detach_shadow_receivers() -> void:
	for actor in actors:
		var shadow=actor.get_node("ActorShadow2D")
		shadow.transfer_pending=true
		shadow.set_process(false)
		if is_instance_valid(shadow.mask_visual): shadow.mask_visual.reparent(shadow,false)
		shadow.receiver=null

func rebind_shadow_receivers(receiver: Node) -> void:
	for actor in actors:
		var shadow=actor.get_node("ActorShadow2D")
		shadow.transfer_pending=false
		if shadow.receiver!=receiver: shadow.bind_receiver(receiver)
