extends Node
## Classroom adapter for the existing ActorShadow2D receiver/mask protocol.
## Environmental models are conservative footprint extrusions, not recovered 3D art.
@onready var lighting: CanvasLayer = get_node("../ClassroomLighting")
@onready var mask: SubViewport = $Mask
@onready var casters: Node2D = $Mask/MapCoordinates/Casters
@onready var _map: Sprite2D = get_node("../Classroom/Presentation/Normal/Artwork")
var prototype_enabled: bool = true
var manifested_mode: bool = false
var _normal_casters_visible: bool = true
var sun_direction: Vector2:
	get: return Vector2.DOWN if manifested_mode else lighting.sun_direction
var length_ratio: float:
	get: return 0.0 if manifested_mode else lighting.length_ratio
var sun_opacity: float:
	get: return 0.0 if manifested_mode else lighting.sun_opacity
var mask_redraw_count: int = 0
var _last_slope := Vector2(INF,INF)

func _ready() -> void:
	process_priority = 5
	mask.world_2d = World2D.new()
	lighting.material.set_shader_parameter("shadow_mask",mask.get_texture())
	lighting.material.set_shader_parameter("shadows_enabled",true)
	add_to_group("actor_shadow_receiver")
	_update_projection()

func _process(_delta: float) -> void:
	_update_projection()

func _update_projection() -> void:
	if manifested_mode:
		return
	var slope: Vector2 = sun_direction * length_ratio
	if slope.distance_to(_last_slope) < 0.001:
		return
	_last_slope = slope
	for caster: Node2D in casters.get_children():
		var footprint: PackedVector2Array = caster.get_meta("footprint")
		var points := footprint.duplicate()
		for vertex in footprint:
			points.append((vertex + slope * float(caster.get_meta("height"))).round())
		var polygon: PackedVector2Array = Geometry2D.convex_hull(points)
		var front: float = -INF
		for vertex in footprint:
			front = maxf(front,vertex.dot(sun_direction))
		var colors := PackedColorArray()
		var reach: float = maxf(1.0,length_ratio * float(caster.get_meta("height")))
		for vertex in polygon:
			var distance: float = clampf((vertex.dot(sun_direction)-front)/reach,0.0,1.0)
			# Polygon vertex colors replace its color: keep cast coverage red-only.
			colors.append(Color(lerpf(0.65,0.4225,distance),0,0,1))
		var sun: Polygon2D = caster.get_node("Sun")
		sun.polygon = polygon
		sun.vertex_colors = colors
	request_actor_shadow_redraw()

func get_actor_shadow_map() -> Sprite2D:
	return _map

## Reuse the same cached mask/ActorShadow2D protocol. Corrupted furniture has no
## verified sunlight geometry, so only contact coverage is admitted in this mode.
func set_presentation_map(artwork: Sprite2D, manifested: bool) -> void:
	if manifested and not manifested_mode:
		_normal_casters_visible = casters.visible
	manifested_mode = manifested
	_map = artwork
	casters.visible = false if manifested else _normal_casters_visible
	_last_slope = Vector2(INF, INF)
	_update_projection()
	request_actor_shadow_redraw()

func attach_actor_shadow(visual: Node2D) -> void:
	visual.reparent($Mask/MapCoordinates,false)
	request_actor_shadow_redraw()

func request_actor_shadow_redraw() -> void:
	mask.render_target_update_mode = SubViewport.UPDATE_ONCE
	mask_redraw_count += 1
