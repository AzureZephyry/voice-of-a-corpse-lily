extends Node
## Local alpha-overlap visibility, following the School Exterior's silhouette rule.
## Source frames and foreground alpha are cached; no shaders or per-frame images.

@export_node_path("AnimatedSprite2D") var actor_sprite_path: NodePath
@export var foreground_paths: Array[NodePath] = []
@export_range(0.1, 1.0, 0.01) var faded_opacity: float = 0.38
@export_range(0.01, 0.5, 0.01) var fade_seconds: float = 0.18
@export_range(0.0, 0.2, 0.01) var clear_delay_seconds: float = 0.08

var obscuring_names: Array[StringName] = []
var _actor: AnimatedSprite2D
var _objects: Array[Dictionary] = []
var _frames: Dictionary = {}
var _last_pose: Array = []


func _ready() -> void:
	_actor = get_node(actor_sprite_path) as AnimatedSprite2D
	refresh_foregrounds()


## Rebind native alpha after the presentation adapter swaps existing textures.
func refresh_foregrounds() -> void:
	for object in _objects:
		if is_instance_valid(object.sprite):
			object.sprite.self_modulate.a = object.original_alpha
	_objects.clear()
	_last_pose.clear()
	for path in foreground_paths:
		var sprite := get_node(path) as Sprite2D
		var alpha := BitMap.new()
		alpha.create_from_image_alpha(sprite.texture.get_image())
		_objects.append({"sprite": sprite, "alpha": alpha,
			"original_alpha": sprite.self_modulate.a, "opacity": 1.0, "clear_time": 0.0})
	# Resolve the new silhouette before its first uncovered frame; subsequent fades
	# retain the approved Normal timing.
	_process(0.0)
	for object in _objects:
		if obscuring_names.has(object.sprite.name):
			object.opacity = faded_opacity
			object.sprite.self_modulate.a = object.original_alpha * faded_opacity


func _process(delta: float) -> void:
	if not is_instance_valid(_actor):
		return
	var texture: Texture2D = _actor.sprite_frames.get_frame_texture(_actor.animation, _actor.frame)
	var pose: Array = [_actor.global_transform, texture, _actor.flip_h, _actor.flip_v, _actor.is_visible_in_tree()]
	if pose != _last_pose:
		_last_pose = pose
		obscuring_names.clear()
		if not _frames.has(texture):
			var alpha := BitMap.new()
			alpha.create_from_image_alpha(texture.get_image())
			_frames[texture] = alpha
		var size: Vector2 = texture.get_size()
		var origin: Vector2 = _actor.offset - size * 0.5 if _actor.centered else _actor.offset
		var actor_rect: Rect2 = _actor.global_transform * Rect2(origin, size)
		for object in _objects:
			var sprite: Sprite2D = object.sprite
			if _actor.is_visible_in_tree() and sprite.is_visible_in_tree() and _overlaps(sprite, object.alpha, _frames[texture], actor_rect, origin):
				obscuring_names.append(sprite.name)
	for object in _objects:
		var sprite: Sprite2D = object.sprite
		var covered: bool = obscuring_names.has(sprite.name)
		object.clear_time = clear_delay_seconds if covered else maxf(0.0, object.clear_time - delta)
		var target: float = faded_opacity if covered or object.clear_time > 0.0 else 1.0
		object.opacity = move_toward(object.opacity, target, delta * (1.0 - faded_opacity) / fade_seconds)
		sprite.self_modulate.a = object.original_alpha * object.opacity


func _overlaps(sprite: Sprite2D, foreground_alpha: BitMap, actor_alpha: BitMap, actor_rect: Rect2, origin: Vector2) -> bool:
	var region: Rect2 = actor_rect.intersection(sprite.global_transform * sprite.get_rect())
	if not region.has_area():
		return false
	var actor_inverse: Transform2D = _actor.global_transform.affine_inverse()
	var foreground_inverse: Transform2D = sprite.global_transform.affine_inverse()
	var actor_size: Vector2i = actor_alpha.get_size()
	var foreground_size: Vector2i = foreground_alpha.get_size()
	for y in range(floori(region.position.y), ceili(region.end.y)):
		for x in range(floori(region.position.x), ceili(region.end.x)):
			var point := Vector2(x + 0.5, y + 0.5)
			var a := Vector2i((actor_inverse * point - origin).floor())
			var f := Vector2i((foreground_inverse * point - sprite.get_rect().position).floor())
			if a.x < 0 or a.y < 0 or a.x >= actor_size.x or a.y >= actor_size.y or f.x < 0 or f.y < 0 or f.x >= foreground_size.x or f.y >= foreground_size.y:
				continue
			if _actor.flip_h:
				a.x = actor_size.x - 1 - a.x
			if _actor.flip_v:
				a.y = actor_size.y - 1 - a.y
			if foreground_alpha.get_bitv(f) and actor_alpha.get_bitv(a):
				return true
	return false


func _exit_tree() -> void:
	for object in _objects:
		if is_instance_valid(object.sprite):
			object.sprite.self_modulate.a = object.original_alpha
