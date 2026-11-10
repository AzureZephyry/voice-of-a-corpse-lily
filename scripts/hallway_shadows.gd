extends Node
## One native-coordinate mask shared by every Hallway actor and structural proxy.
@export var architecture_enabled: bool = true
@export var contacts_enabled: bool = true
@export var casts_enabled: bool = true
@export_range(0.0, 0.8, 0.01) var railing_strength: float = 0.48
@export_range(0.5, 1.5, 0.05) var railing_height_scale: float = 1.0
@onready var lighting: Node = get_node("../HallwayLighting")
@onready var mask: SubViewport = $Mask
@onready var coordinates: Node2D = $Mask/MapCoordinates
@onready var casters: Node2D = $Mask/MapCoordinates/Architecture
@onready var map: Sprite2D = get_node("../Hallway/Background")
@onready var railing_cast: Sprite2D = $Mask/MapCoordinates/Architecture/RailingCast
var prototype_enabled: bool = true
var mask_redraw_count: int = 0
var geometry_updates: int = 0
var _last_slope := Vector2(INF, INF)
var participants: Array[Node2D] = []
var _contacts_enabled: bool = true
var _last_railing_scale: float = -1.0
var _last_railing_strength: float = -1.0
var sun_direction: Vector2:
	get: return lighting.sun_direction
var length_ratio: float:
	get: return lighting.length_ratio
var sun_opacity: float:
	get: return lighting.sun_strength if casts_enabled and not lighting.manifested_active else 0.0

func _ready() -> void:
	process_priority = 15
	mask.world_2d = World2D.new()
	railing_cast.material = railing_cast.material.duplicate()
	map.material.set_shader_parameter("hallway_shadow_mask", mask.get_texture())
	add_to_group("actor_shadow_receiver")
	refresh_projection()

func _process(_delta: float) -> void:
	if contacts_enabled != _contacts_enabled:
		_contacts_enabled = contacts_enabled
		map.material.set_shader_parameter("contacts_enabled", contacts_enabled)
	refresh_projection()

func refresh_projection() -> void:
	participants = participants.filter(func(v): return is_instance_valid(v) and v.get_parent() == coordinates)
	var shown: bool = architecture_enabled and sun_opacity > 0.00001
	if casters.visible != shown:
		casters.visible = shown
		request_actor_shadow_redraw()
	var slope: Vector2 = sun_direction * length_ratio
	if not shown: return
	if slope.distance_squared_to(_last_slope) < 0.000004 and railing_height_scale == _last_railing_scale and railing_strength == _last_railing_strength: return
	_last_slope = slope
	_last_railing_scale = railing_height_scale
	_last_railing_strength = railing_strength
	# One alpha-only draw of Wayne's existing rail. Its image occupies y817..954;
	# projection about the lower edge retains the genuine 26px bar rhythm.
	var rail_slope: Vector2 = slope * railing_height_scale
	railing_cast.transform = Transform2D(Vector2.RIGHT, Vector2(-rail_slope.x, -rail_slope.y), Vector2(0,954)) * Transform2D(0.0, Vector2(44,-137))
	railing_cast.material.set_shader_parameter("strength", railing_strength)
	for caster in casters.get_children():
		if not caster is Polygon2D: continue
		var footprint: PackedVector2Array = caster.get_meta("footprint")
		var points := footprint.duplicate()
		for vertex in footprint:
			points.append(vertex + slope * float(caster.get_meta("height")))
		caster.polygon = Geometry2D.convex_hull(points)
	geometry_updates += 1
	request_actor_shadow_redraw()

func get_actor_shadow_map() -> Sprite2D:
	return map

func attach_actor_shadow(visual: Node2D) -> void:
	if not visual.has_meta("shadow_owner") or not is_instance_valid(visual.get_meta("shadow_owner")):
		visual.set_meta("shadow_owner", visual.get_parent())
	visual.reparent(coordinates, false)
	if not participants.has(visual): participants.append(visual)
	request_actor_shadow_redraw()

func request_actor_shadow_redraw() -> void:
	mask.render_target_update_mode = SubViewport.UPDATE_ONCE
	mask_redraw_count += 1

func refresh_presentation() -> void:
	_last_slope = Vector2(INF, INF)
	# The authority masks both destination frames. Refresh current atlas regions now,
	# before an uncovered destination can appear, rather than waiting one process tick.
	for visual in participants:
		if is_instance_valid(visual):
			var owner_component: Node = visual.get_meta("shadow_owner", null)
			if is_instance_valid(owner_component): owner_component._process(0.0)
	refresh_projection()
	request_actor_shadow_redraw()
