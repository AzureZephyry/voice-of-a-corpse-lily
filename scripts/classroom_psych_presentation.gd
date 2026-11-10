extends CanvasLayer
## Passive Scene 01 presentation: consumes reality signals, never requests them.
@export var entry_pixels: float = 16.0
@export var return_pixels: float = 10.0
@export var aftershock_seconds: float = 0.14
@export var reduced_motion: bool = false
@export var protected_actor_paths: Array[NodePath] = [NodePath("../Foundation/Player/AnimatedSprite2D")]
@export var protected_control_paths: Array[NodePath] = [NodePath("../TimeHUD/Screen/Frame"), NodePath("../StoryLayer/InstructorObjective"), NodePath("../StoryLayer/InstructorPrompt")]
@onready var reality: Node = get_node("../RealityPresentation")
@onready var glitch: CanvasLayer = get_node("../RealityGlitch")
@onready var panel: Control = get_node("../StoryLayer/DialoguePanel")
@onready var fragments: Array = $Echoes.get_children()
@onready var fracture: Control = $FractureLayer/Fracture

# Explicit visual vocabulary/intensity, keyed to existing authored event IDs.
# No voice-string comparisons and no narrative or world-state changes.
const PROFILES: Dictionary = {
	&"did_you": [0, ["DID YOU", "COMMON", "IMPOSTER"]], &"losing_race": [0, ["LOSING THE RACE", "IMPOSTER", "COMMON"]],
	&"slow": [1, ["EXCUSES", "COMMON"]], &"excuses": [1, ["EXCUSES", "FRAUD"]],
	&"die": [1, ["FRAUD", "IMPOSTER"]], &"times_up": [1, ["TOO LATE", "EXCUSES"]],
	&"fraud": [1, ["FRAUD", "COMMON"]], &"imposter": [1, ["IMPOSTER", "FRAUD"]],
	&"is_it": [1, ["COMMON", "EXCUSES"]], &"just_excuses": [1, ["EXCUSES", "FRAUD"]],
	&"embarrassing": [1, ["IMPOSTER", "COMMON"]], &"didnt_have_to": [1, ["COMMON", "EXCUSES"]],
	&"pair_one": [2, ["COMMON", "IMPOSTER", "FRAUD", "EXCUSES"]], &"pair_two": [2, ["TOO LATE", "FRAUD", "COMMON", "LOSING THE RACE"]],
	&"pair_three": [2, ["TOO LATE", "EXCUSES", "IMPOSTER", "FRAUD", "DID YOU", "COMMON"]], &"asshole": [2, ["FRAUD", "COMMON"]],
}
# Irregular event spacing; no sinusoid or repeated frequency.
const TIMES: Array[float] = [0.0,0.035,0.095,0.125,0.195,0.255,0.33,0.405,0.47]
const JITTER: Array[Vector2] = [Vector2(1,-0.4),Vector2(-0.85,0.55),Vector2(0.2,-0.75),Vector2(-1,0.35),Vector2(0.7,0.7),Vector2(-0.45,-0.4),Vector2(0.25,0.15),Vector2(-0.12,-0.1),Vector2.ZERO]
var switch_count: int = 0
var segment_count: int = 0
var active_event: StringName
var _waiting: bool = false
var _vibrating: bool = false
var _vibration_elapsed: float = 0.0
var _toward: int = 0
var _expected_cue: StringName
var _offset := Vector2.ZERO
var _panel_color := Color.WHITE
var _age: float = 0.0
var _lifetime: float = 0.0
var _level: int = 0
var _origins: Array[Vector2] = []
var _elapsed: float = 0.0
var _source: int = 0
var _major: bool = false
var _protectors: Array[AnimatedSprite2D] = []
var _last_protection := PackedVector4Array()

func _ready() -> void:
	process_priority = 25
	for fragment in fragments:
		_origins.append(fragment.position)
		fragment.hide()
	for path in protected_actor_paths:
		_protectors.append(get_node(path))
	fracture.hide()
	reality.transition_started.connect(_on_transition_started)
	reality.transition_finished.connect(_on_transition_finished)
	set_process(false)

func _on_transition_started(from: int, toward: int, cue: StringName) -> void:
	_major = is_major_event(cue, from)
	_restore_panel()
	_clear_fragments()
	_toward = toward
	_source = from
	_elapsed = 0.0
	_expected_cue = cue
	_waiting = true
	switch_count += 1
	set_process(true)

func _on_transition_finished(target: int, cue: StringName) -> void:
	if not _waiting or target != _toward or cue != _expected_cue or reality.state != target: return
	_waiting = false
	fracture.hide()
	_panel_color = panel.modulate
	_vibration_elapsed = 0.0
	_vibrating = true
	if target == reality.State.MANIFESTED:
		var event: StringName = _event_for(cue)
		if has_profile(event): _start_fragments(event)
	set_process(true)

func _event_for(cue: StringName) -> StringName:
	if has_profile(cue): return cue
	var parts: PackedStringArray = String(cue).split(":")
	if parts.size() != 2 or not parts[1].is_valid_int(): return &""
	var host: Node = get_parent().get_node_or_null(NodePath(parts[0]))
	if host == null or not host.has_method("sequence_steps"): return &""
	var steps: Array = host.sequence_steps()
	var index: int = int(parts[1])
	if index < 0 or index >= steps.size() or steps[index].get("reality", 0) != 1: return &""
	return steps[index].id

func _reduced() -> bool:
	return reduced_motion or glitch.is_reduced_motion()

func _start_fragments(event: StringName) -> void:
	active_event = event
	segment_count += 1
	var profile: Array = profile_for(event)
	_level = profile[0]
	_age = 0.0
	_lifetime = 4.0 + float(_level)
	var words: Array = profile[1]
	var count: int = profile[2] if profile.size() > 2 else [5,7,10][_level]
	if event == &"pair_three": count = 12
	_update_protection()
	for i in fragments.size():
		var fragment: Control = fragments[i]
		if i >= count: continue
		fragment.position = _origins[i]
		fragment.configure(words[i % words.size()], 68 + _level * 14 + (14 if i%4==0 else (-10 if i%4==3 else 0)), _level, i * 11 + _level * 7)
		fragment.material.set_shader_parameter("damage", (0.45 if i%3==0 else 0.90) + float(_level) * 0.12)
		fragment.material.set_shader_parameter("pattern_seed", float(17 + i * 11 + _level))
		var palette: Array[Color] = [Color("#c65362"),Color("#a32f40"),Color("#ba747c"),Color("#8a2234"),Color("#d2adb4")]
		fragment.modulate = palette[(i+_level)%palette.size()]
		fragment.modulate.a = 0.0
		fragment.show()

func _process(delta: float) -> void:
	if _waiting:
		_elapsed += delta
		var tick: int = 0
		while tick+1 < TIMES.size() and _elapsed >= TIMES[tick+1]: tick += 1
		var amplitude: float = (entry_pixels if _toward == 2 else return_pixels) + (4.0 if _major else 0.0)
		var move: Vector2 = JITTER[tick] * Vector2(amplitude,8.0 if _toward==2 else 5.0)
		var tearing: float = (16.0 if _major else 10.0) * (1.0 if tick<6 else 0.3)
		if _reduced(): move=Vector2.ZERO; tearing=0.0
		fracture.modulate.a = smoothstep(0.0,0.08,glitch.progress)*(1.0-smoothstep(0.86,1.0,glitch.progress))*(0.70 if _reduced() else 1.0)
		fracture.render(_source==2,_toward==2,glitch.progress,move.round(),tearing,tick)
	if _vibrating:
		_offset = Vector2.ZERO
		_vibration_elapsed += delta
		var t: float = clampf(_vibration_elapsed / aftershock_seconds, 0.0, 1.0)
		if _reduced():
			panel.modulate = _panel_color * Color(1, 1, 1, lerpf(0.94, 1.0, t))
		else:
			var tick: int = mini(int(t * 4),3)
			_offset = (JITTER[tick] * Vector2(5 if _major else 3,2) * (1.0-t)).round()
		panel.position = _panel_rest() + _offset
		if t >= 1.0: _restore_panel()
	if not active_event.is_empty():
		_age += delta
		_update_protection()
		for i in fragments.size():
			var fragment: Control = fragments[i]
			if not fragment.visible: continue
			var local_age: float = _age - float(i) * 0.045 + float(i%3)*0.025
			var fade: float = smoothstep(0.0, 0.14, local_age) * (1.0 - smoothstep(_lifetime - 0.55, _lifetime, _age))
			fragment.modulate.a = fade * (0.94 if i%3==0 else 0.76 + float(_level)*0.06)
			var burst: float = 0.0
			for moment: float in [0.2+float(i%3)*0.09,1.15+float(i%4)*0.19,2.8+float(i%3)*0.21]:
				if local_age>=moment and local_age<moment+0.13: burst = 1.0-(local_age-moment)/0.13
			if _reduced(): burst=0.0
			fragment.position = _origins[i] + Vector2(roundf(((-1 if i%2==0 else 1)*(9+_level*4))*burst),roundf((i%3-1)*6*burst))
			fragment.material.set_shader_parameter("burst",burst)
		if _age >= _lifetime: _clear_fragments()
	if not _waiting and not _vibrating and active_event.is_empty(): set_process(false)

func _update_protection() -> void:
	var rects := PackedVector4Array()
	for actor in _protectors:
		if not actor.is_visible_in_tree(): continue
		var texture: Texture2D = actor.sprite_frames.get_frame_texture(actor.animation,actor.frame)
		var local := Rect2(actor.offset-texture.get_size()*0.5,texture.get_size())
		var r: Rect2 = (actor.get_global_transform_with_canvas()*local).grow(8)
		rects.append(Vector4(r.position.x,r.position.y,r.size.x,r.size.y))
	# Foreground assault may cover NPCs/props, never Albert or essential text.
	for path in protected_control_paths:
		var control: Control = get_node(path)
		if not control.is_visible_in_tree(): continue
		var r: Rect2 = control.get_global_rect().grow(8)
		rects.append(Vector4(r.position.x,r.position.y,r.size.x,r.size.y))
	if panel.is_visible_in_tree():
		var r: Rect2 = panel.get_global_rect().grow_individual(32,8,32,8)
		rects.append(Vector4(r.position.x,r.position.y,r.size.x,r.size.y))
	if rects == _last_protection: return
	_last_protection = rects
	var count: int = rects.size()
	while rects.size()<12: rects.append(Vector4.ZERO)
	for fragment in fragments:
		fragment.material.set_shader_parameter("protected_count",count)
		fragment.material.set_shader_parameter("protected_rects",rects)

func _panel_rest() -> Vector2:
	# Derive rest from authored anchors/current skin, even if a rapid advance
	# resizes Compact between aftershocks. Never subtract an obsolete Y offset.
	var viewport: Vector2 = panel.get_viewport_rect().size
	var bottom: float = -80.0
	return Vector2(viewport.x * panel.anchor_left,viewport.y * panel.anchor_bottom + bottom - panel.size.y)

func _restore_panel() -> void:
	if is_instance_valid(panel):
		if _vibrating:
			panel.position = _panel_rest()
			panel.modulate = _panel_color
	_offset = Vector2.ZERO
	_vibrating = false

func _clear_fragments() -> void:
	active_event = &""
	for fragment in fragments: fragment.hide()

func _exit_tree() -> void:
	_restore_panel()
	_clear_fragments()
	if is_instance_valid(fracture): fracture.hide()


func has_profile(event: StringName) -> bool:
	return PROFILES.has(event)


func profile_for(event: StringName) -> Array:
	return PROFILES[event]


func is_major_event(cue: StringName, _from: int) -> bool:
	return cue in [&"pair_one", &"pair_two", &"pair_three"]
