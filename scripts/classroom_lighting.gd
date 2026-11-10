extends CanvasLayer
## One world-only pass: neutral ambient + continuous daylight + independent lamps.
const DayPhase = preload("res://scripts/day_phase.gd")
const ActorMask = preload("res://scripts/screen_actor_mask.gd")
@export_group("Manifested profile")
@export_range(0.15, 0.65, 0.01) var manifested_exposure: float = 0.36
@export_range(0.0, 0.3, 0.01) var manifested_highlights: float = 0.12
@export_range(0.0, 0.3, 0.01) var manifested_contact_strength: float = 0.16
@export var manifested_tint: Color = Color(0.96, 0.98, 1.0)
var manifested_mode: bool = false
var _fixture_visibility: Array[bool] = []
@onready var protected_actor: AnimatedSprite2D = get_node("../Player/AnimatedSprite2D")
@export_group("Ceiling sources")
@export var reduced_motion: bool = false
@export var electrical_flicker_enabled: bool = true
@export var flicker_seed: int = 173
@export var flicker_interval := Vector2(75,160)
@export var flicker_depth := Vector2(0.10,0.25)
## Normal policy is always on. Keep this public value for existing source controls.
var automatic_ceiling_level: float = 1.0
var _ceiling_initialized: bool = false
var _rng := RandomNumberGenerator.new()
var _next_flicker: float = 100.0
var _flicker_index: int = -1
var _flicker_elapsed: float = 0.0
var _flicker_duration: float = 0.9
var _flicker_amount: float = 0.18
var _last_runtime_usec: int = 0
@onready var ceiling_lights: Array[Node] = [$CeilingLight01,$CeilingLight02,$CeilingLight03,$CeilingLight04]
@export_group("Ambient foundation")
@export var ambient_color: Color = Color.WHITE
@export_range(0.0,1.0,0.01) var ambient_intensity: float = 0.28
@export_group("Window daylight")
@export var daylight_enabled: bool = true
@export var window_fill_radius := Vector2(420,580)
@export_range(0.0,1.0,0.01) var window_fill_strength: float = 0.70
@export_range(0.0,1.0,0.01) var window_direct_strength: float = 0.38
@export var pane_colors: PackedColorArray = [Color(0.48,0.62,0.70),Color(0.73,0.76,0.76),Color(0.66,0.62,0.50),Color(0.78,0.42,0.22),Color(0.12,0.21,0.34),Color(0.025,0.045,0.085),Color(0.18,0.29,0.43)]
@export var window_colors: PackedColorArray = [Color(0.83,0.90,0.93),Color(0.96,0.97,0.97),Color(1,0.89,0.72),Color(1,0.72,0.45),Color(0.48,0.60,0.78),Color(0.48,0.60,0.78),Color(0.52,0.68,0.83)]
@export var window_strengths: PackedFloat32Array = [0.85,1.0,0.78,0.62,0.08,0.0,0.22]
## Casts point away from the north-wall windows; noon is steeper/shorter.
@export var phase_directions: PackedVector2Array = [Vector2(-0.3,1),Vector2(0,1),Vector2(0.3,1),Vector2(0.55,1),Vector2(0.7,1),Vector2(0,1),Vector2(-0.45,1)]
@export var phase_shadow_lengths: PackedFloat32Array = [0.6,0.25,0.75,1.2,1.45,0.0,0.9]
@export var phase_shadow_opacities: PackedFloat32Array = [0.16,0.10,0.20,0.30,0.0,0.0,0.06]
@export var phase_light_reach: PackedFloat32Array = [510,390,550,650,200,160,430]
@export var override_blend_seconds: float = 0.6
@onready var material: ShaderMaterial = $WorldLight.material
var current_phase_index: int = 0
var current_color: Color
var current_window_color: Color
var current_window_strength: float
var current_pane_color: Color
var sun_direction := Vector2.DOWN
var length_ratio: float = 0.6
var sun_opacity: float = 0.0
var light_reach: float = 510.0
var _jump_elapsed: float = 1.0
var _from_color: Color
var _from_window_color: Color
var _from_strength: float
var _from_pane_color: Color
var _from_direction := Vector2.DOWN
var _from_ratio: float
var _from_opacity: float
var _from_reach: float
var _override_active: bool = false
var _override_color: Color = Color.WHITE
var _override_strength: float = 0.0
var _override_pane_color: Color = Color(0,0,0,0)

func _ready() -> void:
	_last_runtime_usec = Time.get_ticks_usec()
	_rng.seed = flicker_seed
	_schedule_flicker()
	GameClock.time_overridden.connect(_on_time_overridden)
	_update(0.0)

func _process(delta: float) -> void:
	_update(delta)
	if manifested_mode:
		ActorMask.apply(material, protected_actor)

## One active world pass. Normal time/source calculations continue underneath;
## this profile never mutates GameClock or paints daylight into the black panes.
func set_manifested_profile(enabled: bool) -> void:
	if enabled == manifested_mode: return
	manifested_mode = enabled
	material.set_shader_parameter("manifested_mode", enabled)
	if enabled:
		_fixture_visibility.clear()
		for fixture in ceiling_lights:
			_fixture_visibility.append(fixture.visible)
			fixture.hide()
		material.set_shader_parameter("manifested_exposure", manifested_exposure)
		material.set_shader_parameter("manifested_highlights", manifested_highlights)
		material.set_shader_parameter("manifested_contact_strength", manifested_contact_strength)
		material.set_shader_parameter("manifested_tint", manifested_tint)
		ActorMask.apply(material, protected_actor)
	else:
		for i in ceiling_lights.size(): ceiling_lights[i].visible = _fixture_visibility[i]
		_fixture_visibility.clear()

func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED:
		# Runtime flicker is independent of story-clock holds, but a true game
		# pause must not jump its electrical animation forward on resume.
		_last_runtime_usec = Time.get_ticks_usec()

func _sample_daylight(minutes: float) -> Dictionary:
	# Full-interval quintic interpolation: the sun evolves throughout each daylight
	# phase, with matching endpoints/zero endpoint derivatives (no boundary snaps).
	var state: Dictionary = DayPhase.sample(minutes,DayPhase.STARTS,1440.0)
	# Keep the long night dark; only its final hour approaches the Dawn profile.
	if state.index == 5:
		return DayPhase.sample(minutes)
	return state

func _update(delta: float) -> void:
	var state: Dictionary = _sample_daylight(GameClock.get_minutes())
	current_phase_index = state.index
	# Ambient is independent of time. Daylight supplies every phase-dependent lift.
	var color := Color(ambient_color.r*ambient_intensity,ambient_color.g*ambient_intensity,ambient_color.b*ambient_intensity,1.0)
	var window: Color = window_colors[state.index].lerp(window_colors[state.next], state.weight)
	var strength: float = lerpf(window_strengths[state.index], window_strengths[state.next], state.weight)
	var pane: Color = pane_colors[state.index].lerp(pane_colors[state.next], state.weight)
	var direction: Vector2 = phase_directions[state.index].lerp(phase_directions[state.next],state.weight).normalized()
	var ratio: float = lerpf(phase_shadow_lengths[state.index],phase_shadow_lengths[state.next],state.weight)
	var opacity: float = lerpf(phase_shadow_opacities[state.index],phase_shadow_opacities[state.next],state.weight)
	# Electrical behavior and source fades use monotonic real time, not held story
	# time. Clamp long suspension gaps so resuming cannot skip a complete flicker.
	var now: int = Time.get_ticks_usec()
	var runtime_delta: float = clampf(float(now-_last_runtime_usec)/1000000.0,0.0,0.25)
	_last_runtime_usec = now
	_update_ceiling(runtime_delta)
	var reach: float = lerpf(phase_light_reach[state.index],phase_light_reach[state.next],state.weight)
	if _override_active:
		color = _override_color
		strength = _override_strength
		opacity = 0.0
		if _override_pane_color.a > 0.0:
			pane = _override_pane_color
	if not daylight_enabled:
		strength = 0.0
		opacity = 0.0
	_jump_elapsed += delta
	var blend: float = smoothstep(0.0, override_blend_seconds, _jump_elapsed)
	current_color = _from_color.lerp(color, blend) if blend < 1.0 else color
	current_window_color = _from_window_color.lerp(window, blend) if blend < 1.0 else window
	current_window_strength = lerpf(_from_strength, strength, blend) if blend < 1.0 else strength
	current_pane_color = _from_pane_color.lerp(pane, blend) if blend < 1.0 else pane
	sun_direction = _from_direction.lerp(direction,blend).normalized() if blend < 1.0 else direction
	length_ratio = lerpf(_from_ratio,ratio,blend) if blend < 1.0 else ratio
	sun_opacity = lerpf(_from_opacity,opacity,blend) if blend < 1.0 else opacity
	light_reach = lerpf(_from_reach,reach,blend) if blend < 1.0 else reach
	material.set_shader_parameter("ambient_color", current_color)
	material.set_shader_parameter("window_color", current_window_color)
	material.set_shader_parameter("window_strength", current_window_strength)
	material.set_shader_parameter("window_fill_radius",window_fill_radius)
	material.set_shader_parameter("window_fill_strength",window_fill_strength)
	material.set_shader_parameter("window_direct_strength",window_direct_strength)
	material.set_shader_parameter("pane_color", current_pane_color)
	material.set_shader_parameter("viewport_size", get_viewport().get_visible_rect().size)
	material.set_shader_parameter("sun_direction",sun_direction)
	material.set_shader_parameter("sun_opacity",sun_opacity)
	material.set_shader_parameter("light_reach",light_reach)
	# This existing Node2D marker is UI in world space; preserve its actual colors.
	var marker=get_parent().get_parent().get_node_or_null("InstructorMarker")
	var marker_rect:=Vector4.ZERO
	if marker!=null and marker.is_visible_in_tree():
		var origin: Vector2=marker.global_position-Vector2(4,3)*marker.global_scale
		var size: Vector2=Vector2(8,6)*marker.global_scale
		marker_rect=Vector4(origin.x,origin.y,size.x,size.y)
	material.set_shader_parameter("interaction_marker_rect",marker_rect)

func _schedule_flicker() -> void:
	_next_flicker = _rng.randf_range(maxf(30.0,flicker_interval.x),maxf(30.0,flicker_interval.y))

func flicker_suppressed() -> bool:
	var quiz: Node = get_parent().get_parent().get_node_or_null("QuizSequence")
	return reduced_motion or (quiz != null and quiz.get("reduced_motion") == true)

## Explicit single-source cue; normal electrical scheduling never invokes story events.
func trigger_electrical_dip(index: int, depth: float = 0.18, duration: float = 0.9) -> bool:
	if index<0 or index>=4 or _flicker_index>=0 or flicker_suppressed(): return false
	var source: Node = ceiling_lights[index]
	if not source.flicker_enabled or source.current_intensity<0.05: return false
	_flicker_index=index
	_flicker_elapsed=0.0
	_flicker_amount=clampf(depth,0.10,0.25)
	_flicker_duration=maxf(duration,0.6)
	return true

func _update_ceiling(delta: float) -> void:
	# Daylight never shuts down these fixtures. Explicit source overrides still win.
	var desired: float = 1.0
	automatic_ceiling_level=desired
	var suppressed: bool = flicker_suppressed()
	if suppressed: _flicker_index=-1
	if _flicker_index<0 and electrical_flicker_enabled and not suppressed:
		_next_flicker-=delta
		if _next_flicker<=0:
			var eligible: Array[int]=[]
			for i in range(4):
				if ceiling_lights[i].flicker_enabled and not ceiling_lights[i].manual_override and ceiling_lights[i].current_intensity>0.05: eligible.append(i)
			if not eligible.is_empty():
				trigger_electrical_dip(eligible[_rng.randi_range(0,eligible.size()-1)])
			_schedule_flicker()
	var dip: float=0.0
	if _flicker_index>=0:
		_flicker_elapsed+=delta
		var t: float=clampf(_flicker_elapsed/_flicker_duration,0,1)
		dip=_flicker_amount*pow(sin(PI*t),2.0)
		if t>=1.0: _flicker_index=-1
	var sources:=PackedVector4Array()
	var colors:=PackedColorArray()
	var reaches:=PackedVector2Array()
	var heights:=PackedFloat32Array()
	for i in range(4):
		var source: Node=ceiling_lights[i]
		if not _ceiling_initialized: source._level=source.override_intensity if source.manual_override else (source.intensity*desired if source.enabled else 0.0)
		source.update_source(delta,desired,dip if i==_flicker_index else 0.0)
		sources.append(Vector4(source.floor_position.x,source.floor_position.y,source.current_intensity,source.falloff))
		colors.append(source.color)
		reaches.append(source.reach)
		heights.append(source.emitter_height)
	_ceiling_initialized=true
	material.set_shader_parameter("ceiling_sources",sources)
	material.set_shader_parameter("ceiling_colors",colors)
	material.set_shader_parameter("ceiling_reach",reaches)
	material.set_shader_parameter("ceiling_heights",heights)

func _on_time_overridden(_previous: float, _current: float) -> void:
	_from_color = current_color
	_from_window_color = current_window_color
	_from_strength = current_window_strength
	_from_pane_color = current_pane_color
	_from_direction = sun_direction
	_from_ratio = length_ratio
	_from_opacity = sun_opacity
	_from_reach = light_reach
	_jump_elapsed = 0.0

## Independent source control; diagnostics disable only window irradiance, not panes.
func set_daylight_enabled(enabled: bool) -> void:
	if daylight_enabled == enabled:
		return
	if is_node_ready():
		_on_time_overridden(0,0)
	daylight_enabled = enabled

## Future perception can override this pass without mutating the global time.
func set_environment_override(color: Color, window_strength: float = 0.0, pane_color: Color = Color(0,0,0,0)) -> void:
	_on_time_overridden(0,0)
	_override_active = true
	_override_color = color
	_override_strength = window_strength
	_override_pane_color = pane_color

func clear_environment_override() -> void:
	_on_time_overridden(0,0)
	_override_active = false

func _exit_tree() -> void:
	if GameClock.time_overridden.is_connected(_on_time_overridden):
		GameClock.time_overridden.disconnect(_on_time_overridden)
