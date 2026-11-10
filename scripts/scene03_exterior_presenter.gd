extends Node
## Local asset/lighting adapter. RealityPresentation alone owns reality state.
const MANIFESTED = preload("res://assets/environments/school_exterior/composite/school_manifested_saved_composite.png")
const MANIFESTED_MASK = preload("res://assets/environments/school_exterior/composite/school_manifested_occlusion_mask.png")
const NORMAL_MASK = preload("res://assets/environments/school_exterior/composite/school_notice_board_occlusion_mask.png")
const GUARD_MANIFESTED = preload("res://assets/characters/mang_arnel/manifested/mang_arnel_manifested_frames.tres")
var _guard_normal: SpriteFrames
var _normal: Array[Dictionary] = []
var _materials: Array[ShaderMaterial] = []
var active: bool = false
var _normal_only: Array[CanvasItem] = []
@onready var host: Node = get_parent()
@onready var room: Node2D = get_node("../SchoolExterior")
@onready var sun: Node = room.get_node("SunShadowPrototype")
@onready var board: Sprite2D = room.get_node("Occluders/NoticeBoardComposition/Artwork")
var _normal_board: Rect2
var _normal_position: Vector2
var _normal_sun: float

func _ready() -> void:
	_normal_only.assign([room.get_node("OcclusionUnderlay"),room.get_node("NoticeBoardGroundUnderlay"),room.get_node("AntennaUnderlays"),room.get_node("Car11GroundPatch"),room.get_node("Occluders/NorthFacingCar11")])
	_guard_normal=get_node("../MangArnel/AnimatedSprite2D").sprite_frames
	_normal_sun=sun.maximum_sun_opacity
	_normal_board=board.region_rect
	_normal_position=board.position
	for item: Sprite2D in room.find_children("*","Sprite2D",true,false):
		if item.texture != null and item.texture.resource_path.ends_with("school_normal_with_notice_board.png"):
			_normal.append({"sprite":item,"texture":item.texture})
		if item.material is ShaderMaterial and not _materials.has(item.material): _materials.append(item.material)

func can_present_manifested() -> bool:
	return not _normal.is_empty()

func present_manifested() -> void:
	active=true
	_swap_guard(GUARD_MANIFESTED)
	if host.has_node("AmbientStudents"): host.get_node("AmbientStudents").set_manifested(true)
	host.get_node("BoardInteraction").suspended=true
	for item in _normal_only: item.hide()
	room.set_process(false)
	room.get_node("Lighting").hide()
	room.ambient.color=Color.WHITE
	room.get_node("GroundFog").set_process(false)
	room.get_node("GroundFog").hide()
	for entry in _normal: entry.sprite.texture=MANIFESTED
	board.region_rect=Rect2(455,1006,52,46)
	board.position=Vector2(455,1006)*1.1475-board.get_parent().position
	host.use_occlusion(MANIFESTED_MASK)
	for material in _materials:
		material.set_shader_parameter("grade_saturation",1.0)
		material.set_shader_parameter("grade_contrast",1.0)
		material.set_shader_parameter("shadow_strength",0.0)
		if material.shader.resource_path.ends_with("school_foreground_mask.gdshader"):
			material.set_shader_parameter("occlusion_mask",MANIFESTED_MASK)
			material.set_shader_parameter("fade_enabled",false)
	room.get_node("Map").material.set_shader_parameter("occlusion_mask",MANIFESTED_MASK)
	sun.maximum_sun_opacity=0.0
	sun._process(0.0)

func present_normal() -> void:
	active=false
	_swap_guard(_guard_normal)
	if host.has_node("AmbientStudents"): host.get_node("AmbientStudents").set_manifested(false)
	host.get_node("BoardInteraction").suspended=false
	for item in _normal_only: item.show()
	for entry in _normal: entry.sprite.texture=entry.texture
	board.region_rect=_normal_board
	board.position=_normal_position
	host.use_occlusion(NORMAL_MASK)
	for material in _materials:
		if material.shader.resource_path.ends_with("school_foreground_mask.gdshader"): material.set_shader_parameter("occlusion_mask",NORMAL_MASK)
	room.get_node("Map").material.set_shader_parameter("occlusion_mask",NORMAL_MASK)
	for object: Dictionary in host._objects.values(): object.material.set_shader_parameter("fade_enabled",true)
	sun.maximum_sun_opacity=_normal_sun
	room.get_node("Lighting").show()
	room.get_node("GroundFog").show()
	room.get_node("GroundFog").set_process(true)
	room.set_process(true)
	room._applied_grading=Vector3(-1,-1,-1)
	room._update_lighting()
	sun._process(0.0)

func _swap_guard(frames: SpriteFrames) -> void:
	var sprite: AnimatedSprite2D=get_node("../MangArnel/AnimatedSprite2D")
	var animation: StringName=sprite.animation
	var frame: int=sprite.frame
	var progress: float=sprite.frame_progress
	sprite.sprite_frames=frames
	sprite.play(animation)
	sprite.set_frame_and_progress(frame,progress)
