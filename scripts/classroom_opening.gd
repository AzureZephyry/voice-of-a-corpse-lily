extends Node2D
## Black, classroom reveal and the two approved thoughts; hand off via opening_finished.

signal opening_finished
## Integration boundary only: no approved Hallway scene/transition exists yet.
signal scene_completed
signal audio_cued(cue_id: StringName)

const DialoguePanel = preload("res://scripts/dialogue_panel.gd")
const Typewriter = preload("res://scripts/text_type.gd")
const LINES: PackedStringArray = ["Okay.", "Okay. Okay."]

enum Phase { BLACK, FADING, DIALOGUE, COMPLETE }

@export_range(0.0, 4.0, 0.1) var black_hold_seconds: float = 0.8
@export_range(0.1, 8.0, 0.1) var reveal_seconds: float = 2.5
## Assign Lawrence's approved clock stream here. No substitute audio is supplied.
@export var clock_ticking_stream: AudioStream

@onready var player: CharacterBody2D = $Foundation/Player
@onready var panel: DialoguePanel = $StoryLayer/DialoguePanel
@onready var body: Typewriter = $StoryLayer/DialoguePanel/Margin/Content/Body
@onready var blackout: ColorRect = $RevealLayer/Blackout
@onready var clock: AudioStreamPlayer = $ClockTicking

var phase: Phase = Phase.BLACK
var line_index: int = 0
var _held_keys: Dictionary = {}
var _mouse_held: bool = false
var _last_accept_frame: int = -1
var _reveal: Tween
var completed_once: bool = false
var professor_finished: bool=false

func _on_professor_conversation_finished() -> void:
	if professor_finished: return
	professor_finished=true
	$ClassroomExit.unlock()

func _on_classroom_exit() -> void:
	if completed_once or not professor_finished or $RealityPresentation.state!=0: return
	completed_once=true
	$DismissalSequence.objective.complete_current()
	player.velocity=Vector2.ZERO
	player.set_physics_process(false)
	scene_completed.emit()


func _ready() -> void:
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	# The story host owns key/click routing, as in the existing Bedroom intro.
	# Text reveal, typography and world artwork remain in the shared dialogue UI.
	body.set_process_unhandled_key_input(false)
	body.clear_line()
	panel.hide()
	panel.world = DialoguePanel.World.REAL
	panel.speaker_name = "Albert"
	blackout.color = Color.BLACK
	blackout.show()
	get_window().focus_exited.connect(_clear_held_inputs)
	for key: int in [KEY_E, KEY_SPACE]:
		if Input.is_physical_key_pressed(key):
			_held_keys[key] = true
	_mouse_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if clock_ticking_stream != null:
		clock.stream = clock_ticking_stream
		clock.play()
	audio_cued.emit(&"clock_ticking_start")
	await get_tree().create_timer(black_hold_seconds).timeout
	phase = Phase.FADING
	_reveal = create_tween()
	_reveal.tween_property(blackout, "color:a", 0.0, reveal_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _reveal.finished
	blackout.hide()
	phase = Phase.DIALOGUE
	_present_line()


func _present_line() -> void:
	panel.show()
	body.present_line(LINES[line_index])


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action(&"dialogue_advance"):
		get_viewport().set_input_as_handled()
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if not event.pressed:
			_held_keys.erase(key)
			return
		if event.echo or _held_keys.has(key):
			return
		_held_keys[key] = true
		_advance_or_reveal()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		if not event.pressed:
			_mouse_held = false
			return
		if _mouse_held:
			return
		_mouse_held = true
		if get_viewport_rect().has_point(event.position):
			_advance_or_reveal()


func _advance_or_reveal() -> void:
	if phase != Phase.DIALOGUE:
		return
	var frame: int = Engine.get_process_frames()
	if frame <= _last_accept_frame:
		return
	_last_accept_frame = frame
	if body.is_typing:
		body.reveal_line()
		return
	panel.notify_accepted_advance(true) # Next thought, or quiz dialogue after its staging cue.
	line_index += 1
	if line_index < LINES.size():
		_present_line()
		return
	body.clear_line()
	panel.hide()
	phase = Phase.COMPLETE
	# The quiz takes ownership of this same panel and input after the two thoughts.
	set_process_input(false)
	opening_finished.emit()


func _clear_held_inputs() -> void:
	_held_keys.clear()
	_mouse_held = false
	_last_accept_frame = Engine.get_process_frames()


func _exit_tree() -> void:
	if is_instance_valid(_reveal):
		_reveal.kill()