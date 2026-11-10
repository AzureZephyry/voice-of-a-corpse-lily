extends "res://scripts/classroom_quiz.gd"
## One local coordinator; shared runner owns dialogue input and reality readiness.
signal hallway_segment_completed
signal stage_changed(stage: int)
const Screenplay = preload("res://scripts/hallway_screenplay.gd")
enum Stage { ENCOUNTER, CONVERSATION, DEPARTURE, FRIENDS, FREE, DONE, CANCELLED }
var stage: Stage = Stage.ENCOUNTER
var encounter_started: bool = false
var completion_count: int = 0
var event_trace: Array[Dictionary] = []
var departure_x: float = 3390.0
@export var story_reduced_motion: bool = false
@export_group("Authored walking manifestations")
@export var traversal_x: PackedFloat32Array = [3000.0,2050.0,900.0]
@export var traversal_holds: PackedFloat32Array = [0.70,0.90,0.75]
var traversal_trace: Array[Dictionary] = []
var next_traversal_beat: int = 0
var active_traversal_beat: int = -1
var traversal_remaining: float = 0.0
var _previous_walk_x: float = 0.0
var _traversal_cue: StringName
@onready var jules: CharacterBody2D = get_node("../Cast/Jules")
@onready var liezel: CharacterBody2D = get_node("../Cast/Liezel")


func _ready() -> void:
	super._ready()
	reduced_motion = story_reduced_motion
	get_node("../RealityGlitch").reduced_motion = story_reduced_motion
	body.preserve_source_punctuation = true
	# Engine-shipped fallback supplies punctuation absent from the team's font.
	var font: Font = body.get_theme_font("font").duplicate()
	var punctuation := FontVariation.new()
	punctuation.base_font = ThemeDB.fallback_font
	punctuation.variation_transform = Transform2D(Vector2(0.55, 0), Vector2(0, 0.55), Vector2.ZERO)
	font.fallbacks = [punctuation]
	body.add_theme_font_override("font", font)
	stage_direction.connect(_on_stage)
	quiz_finished.connect(_on_dialogue_finished)
	reality.transition_finished.connect(_on_traversal_reality_finished)
	player.set_control(false)
	body.set_process_unhandled_key_input(false)


func begin_encounter() -> bool:
	if encounter_started or stage != Stage.ENCOUNTER: return false
	encounter_started = true
	_change_stage(Stage.CONVERSATION)
	player.set_control(true)
	_on_opening_finished()
	return true


func sequence_steps() -> Array[Dictionary]:
	return Screenplay.STEPS


func display_text(source: String) -> String:
	return source


func _present_step() -> void:
	super._present_step()
	if step_index >= sequence_steps().size(): return
	var entry: Dictionary = sequence_steps()[step_index]
	if entry.has("text"):
		if entry.get("classification") == "heard":
			body.add_theme_color_override("font_color", Color("#e0a3af"))
		_face_speakers(entry)
	event_trace.append({"id":entry.id, "text":entry.get("text", ""),
		"origin":entry.get("origin", ""), "classification":entry.get("classification", "cue"),
		"paragraph":entry.source_paragraph, "reality":reality.state,
		"clock":GameClock.get_minutes(), "position":player.position,
		"jules_frames":jules.animated_sprite.sprite_frames.resource_path,
		"liezel_frames":liezel.animated_sprite.sprite_frames.resource_path})


func _face_speakers(entry: Dictionary) -> void:
	if entry.id == &"something_wrong":
		jules.face_direction(Vector2.LEFT)
		liezel.face_direction(Vector2.LEFT)
	elif entry.id in [&"liezel_rebuke", &"oh_my_god", &"no", &"dont_think_so"]:
		jules.face_direction(liezel.position - jules.position)
		liezel.face_direction(jules.position - liezel.position)
	else:
		jules.face_direction(player.position - jules.position)
		liezel.face_direction(player.position - liezel.position)


func _on_stage(id: StringName, _direction: String) -> void:
	match id:
		&"students_waiting":
			hold_remaining = 0.35
		&"liezel_softens": liezel.face_direction(player.position - liezel.position)
		&"shared_laughter":
			jules.face_direction(liezel.position - jules.position)
			liezel.face_direction(jules.position - liezel.position)
		&"walk_past":
			hold_remaining = INF
			departure_x = minf(3390.0, player.position.x - 120.0)
			_change_stage(Stage.DEPARTURE)
			jules.face_direction(Vector2.LEFT)
			liezel.face_direction(Vector2.LEFT)
			player.set_control(false)
		&"lingering_watch": liezel.face_direction(Vector2.LEFT)


func _physics_process(delta: float) -> void:
	if stage == Stage.DEPARTURE and player.position.x <= departure_x:
		player.set_control(true)
		player.animated_sprite.update_motion(Vector2.LEFT, Vector2.ZERO)
		player.set_physics_process(false)
		_change_stage(Stage.FRIENDS)
		hold_remaining = 0.0
	elif stage == Stage.FREE:
		_tick_traversal(delta)
		# A fast approach cannot remove the environment under an active pulse.
		if player.position.x <= 320.0 and active_traversal_beat < 0 and reality.state == reality.State.NORMAL:
			completion_count += 1
			_change_stage(Stage.DONE)
			get_node("../StoryLayer/Completion").show()
			hallway_segment_completed.emit()

func _tick_traversal(delta: float) -> void:
	var walking_left: bool = player.position.x < _previous_walk_x-0.01
	_previous_walk_x = player.position.x
	if active_traversal_beat >= 0:
		if reality.state == reality.State.MANIFESTED:
			traversal_remaining = maxf(0.0,traversal_remaining-delta)
			if traversal_remaining <= 0.0: reality.request_normal(_traversal_cue)
		return
	if not walking_left or next_traversal_beat >= traversal_x.size() or reality.state != reality.State.NORMAL: return
	if player.position.x > traversal_x[next_traversal_beat]: return
	var cue := StringName("hallway_walk_%02d" % (next_traversal_beat+1))
	if not reality.request_manifestation(cue): return
	active_traversal_beat = next_traversal_beat
	_traversal_cue = cue
	_record_traversal(&"requested")

func _on_traversal_reality_finished(target: int, cue: StringName) -> void:
	if stage != Stage.FREE or active_traversal_beat < 0 or cue != _traversal_cue: return
	if target == reality.State.MANIFESTED:
		traversal_remaining = traversal_holds[active_traversal_beat] if active_traversal_beat < traversal_holds.size() else 0.75
		_record_traversal(&"manifested")
	elif target == reality.State.NORMAL:
		_record_traversal(&"restored")
		next_traversal_beat += 1
		active_traversal_beat = -1

func _record_traversal(event: StringName) -> void:
	traversal_trace.append({"event":event,"cue":_traversal_cue,"beat":active_traversal_beat,
		"x":player.position.x,"clock":GameClock.get_minutes(),"state":reality.state,
		"control_locked":player.control_locked})


func _change_stage(next: Stage) -> void:
	stage = next
	stage_changed.emit(stage)


func _on_dialogue_finished() -> void:
	body.clear_line()
	panel.hide()
	player.set_control(false)
	_previous_walk_x = player.position.x
	_change_stage(Stage.FREE)


func cancel_sequence() -> void:
	if stage in [Stage.DONE, Stage.CANCELLED]: return
	_change_stage(Stage.CANCELLED)
	active_traversal_beat = -1
	traversal_remaining = 0.0
	_step_pending = false
	phase = Phase.COMPLETE
	set_process(false)
	set_process_input(false)
	body.interrupt_reveal()
	body.clear_line()
	panel.hide()
	reality.cancel_transition()
	if reality.state == reality.State.MANIFESTED:
		reality.request_normal(&"hallway_cancel")
	player.set_control(false)


func _exit_tree() -> void:
	_step_pending = false
	super._exit_tree()
	if is_instance_valid(body): body.clear_line()
	if is_instance_valid(panel): panel.hide()
