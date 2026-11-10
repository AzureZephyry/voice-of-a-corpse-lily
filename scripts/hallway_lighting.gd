extends Node
## One Hallway illumination owner; shared clock and reality authority remain external.
const DayPhase = preload("res://scripts/day_phase.gd")
@export var visual_paths: Array[NodePath] = []
@export var additional_actor_roots: Array[NodePath] = []
@export var enabled: bool = true
@export var phase_colors: PackedColorArray = [Color("e9f0f4"),Color("fff7ed"),Color("ead8c1"),Color("d4b9b7"),Color("a7adc3"),Color("a1acc2"),Color("c1c9db")]
@export_range(0.15, 0.6, 0.01) var night_ambient: float = 0.30
@export_range(0.2, 0.7, 0.01) var day_ambient: float = 0.38
@export_range(0.0, 0.6, 0.01) var diffuse_gain: float = 0.30
@export_range(0.0, 0.6, 0.01) var direct_gain: float = 0.28
@export_group("Borrowed classroom daylight")
@export_range(0.0, 0.20, 0.005) var window_spill_gain: float = 0.12
@export_range(0.0, 0.40, 0.01) var window_glass_gain: float = 0.26
## Interior glass bounds sampled from the existing Normal export; no new openings.
@export var door_windows: PackedVector4Array = [Vector4(598,214,55,43),Vector4(1185,214,54,43),Vector4(1768,214,55,43),Vector4(2355,214,54,43),Vector4(2937,214,55,43),Vector4(3524,214,54,43)]
@export var thin_windows: PackedVector4Array = [Vector4(699,162,210,13),Vector4(945,162,210,13),Vector4(1869,162,210,13),Vector4(2115,162,210,13),Vector4(3038,162,210,13),Vector4(3284,162,210,13)]
@onready var ground_material: ShaderMaterial = get_node("../Hallway/Background").material
var sample: Dictionary = {}
var current_tint: Color = Color.WHITE
var current_energy: float = 1.0
var manifested_active: bool = false
var sun_direction := Vector2.UP
var length_ratio: float = 0.45
var sun_strength: float = 0.0
var ambient: float = 0.30
var diffuse: float = 0.0
var materials: Array[ShaderMaterial] = []
var _last_uniforms: Array = []

func _ready() -> void:
	process_priority = -5
	ground_material.set_shader_parameter("door_windows",door_windows)
	ground_material.set_shader_parameter("thin_windows",thin_windows)
	for path in visual_paths:
		var material: Material = get_node(path).material
		if material is ShaderMaterial and not materials.has(material): materials.append(material)
	var rail_material: ShaderMaterial = get_node("../RailingVisibility").overlap_material
	if not materials.has(rail_material): materials.append(rail_material)
	for path in additional_actor_roots:
		for sprite in get_node(path).find_children("*", "AnimatedSprite2D", true, false):
			if sprite.material is ShaderMaterial and not materials.has(sprite.material): materials.append(sprite.material)
	get_node("../HallwayRealityPresenter").presentation_changed.connect(_on_presentation_changed)
	_process(0.0)

## +Y faces the open rail; casts travel inward toward -Y. X drifts west to east.
## Structural heights are projected artistic approximations, not recovered 3D.
func sample_sun(minutes: float) -> Dictionary:
	var hour: float = fposmod(minutes, 1440.0) / 60.0
	var progress: float = clampf((hour-5.0)/14.5, 0.0, 1.0)
	var elevation: float = maxf(0.0, sin(progress*PI)) if hour >= 5.0 and hour <= 19.5 else 0.0
	var strength: float = pow(elevation, 0.65) * (1.0-smoothstep(17.5,19.5,hour))
	return {"direction":Vector2(lerpf(-0.85,0.85,progress),-1.0).normalized(),
		"ratio":lerpf(2.4,0.70,elevation), "strength":strength,
		"ambient":lerpf(night_ambient,day_ambient,sqrt(elevation)),
		"diffuse":diffuse_gain*pow(elevation,0.4)}

func _process(_delta: float) -> void:
	sample = DayPhase.sample(GameClock.get_minutes())
	current_tint = phase_colors[sample.index].lerp(phase_colors[sample.next], sample.weight)
	var sun: Dictionary = sample_sun(GameClock.get_minutes())
	sun_direction = sun.direction
	length_ratio = sun.ratio
	sun_strength = sun.strength
	ambient = sun.ambient
	diffuse = sun.diffuse
	var uniforms: Array = [enabled,current_tint,ambient,diffuse,sun_strength,manifested_active,window_spill_gain,window_glass_gain]
	if uniforms == _last_uniforms: return
	_last_uniforms = uniforms
	# Diffuse light borrowed through existing classroom openings, not another sun
	# or a night-time lamp. Suppressed at the same accepted reality midpoint.
	ground_material.set_shader_parameter("window_spill_energy",window_spill_gain * clampf(diffuse / maxf(diffuse_gain,0.001),0.0,1.0) if enabled and not manifested_active else 0.0)
	ground_material.set_shader_parameter("window_glass_energy",window_glass_gain * clampf(diffuse / maxf(diffuse_gain,0.001),0.0,1.0) if enabled and not manifested_active else 0.0)
	for material in materials:
		material.set_shader_parameter("time_enabled",enabled)
		material.set_shader_parameter("time_tint",current_tint)
		material.set_shader_parameter("ambient_energy",ambient)
		material.set_shader_parameter("diffuse_energy",diffuse)
		material.set_shader_parameter("direct_energy",direct_gain*sun_strength)
		material.set_shader_parameter("manifested",manifested_active)

func _on_presentation_changed(active: bool) -> void:
	manifested_active = active
	_process(0.0)
	get_node("../HallwayShadows").refresh_presentation()
