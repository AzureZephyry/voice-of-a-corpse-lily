extends "res://scripts/classroom_quiz.gd"
## Source paragraphs 18–30. No invented bench, scratches, gesture or phone UI.
signal exterior_segment_completed
const Screenplay = preload("res://scripts/scene02_exterior_screenplay.gd")
@export var autostart: bool = true
@export var story_reduced_motion: bool = false
var started: bool = false
var completed: bool = false
var cancelled: bool = false
var walking: bool = false
var completion_count: int = 0
var event_trace: Array[Dictionary] = []

func _ready() -> void:
	super._ready()
	reduced_motion = story_reduced_motion or reduced_motion
	body.preserve_source_punctuation = true
	var font: Font = body.get_theme_font("font").duplicate()
	var punctuation := FontVariation.new()
	punctuation.base_font = ThemeDB.fallback_font
	punctuation.variation_transform = Transform2D(Vector2(.55,0),Vector2(0,.55),Vector2.ZERO)
	font.fallbacks = [punctuation]
	body.add_theme_font_override("font", font)
	stage_direction.connect(_on_stage)
	quiz_finished.connect(_on_finished)
	player.set_control(true)
	if autostart: begin_sequence.call_deferred()

func begin_sequence() -> bool:
	if started or cancelled: return false
	started = true
	_on_opening_finished()
	return true

func sequence_steps() -> Array[Dictionary]:
	return Screenplay.STEPS

func display_text(source: String) -> String:
	return source

func _present_step() -> void:
	super._present_step()
	if step_index >= sequence_steps().size(): return
	var e: Dictionary = sequence_steps()[step_index]
	if e.get("classification") == "heard_no_trigger":
		# An internal echo, not a missed world transition or another external voice.
		body.add_theme_color_override("font_color", Color("#79505c"))
	event_trace.append({"id":e.id,"text":e.get("text",""),"origin":e.get("origin",""),"classification":e.get("classification","cue"),"paragraph":e.source_paragraph,"reality":reality.state,"clock":GameClock.get_minutes(),"position":player.position})

func _on_stage(id: StringName, _direction: String) -> void:
	if id == &"walk_without_choosing":
		walking = true
		player.set_control(true, Vector2.DOWN)

func _physics_process(_delta: float) -> void:
	if walking and player.position.y >= 849.0:
		walking = false
		player.position.y = 850
		player.set_control(true)
		player.animated_sprite.update_motion(Vector2.RIGHT, Vector2.ZERO)
		player.set_physics_process(false)
		hold_remaining = 0.0

func _on_finished() -> void:
	if completed or cancelled: return
	if phase != Phase.COMPLETE or step_index < sequence_steps().size(): return
	completed = true
	completion_count += 1
	body.clear_line()
	panel.hide()
	player.set_control(false)
	exterior_segment_completed.emit()

func cancel_sequence() -> void:
	if completed or cancelled: return
	cancelled = true
	walking = false
	_step_pending = false
	phase = Phase.COMPLETE
	set_process(false)
	set_process_input(false)
	body.clear_line()
	panel.hide()
	get_node("../ExteriorAudio").cancel_presentation()
	player.set_control(false)

func _exit_tree() -> void:
	_step_pending = false
	super._exit_tree()
	if is_instance_valid(body): body.clear_line()
