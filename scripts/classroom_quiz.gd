extends Node
## Scene 01 quiz only; shares the opening's Reality panel and typewriter.
## Source: docs/story/source/scene_01_time_called.docx, paragraphs 7–22.
## Stop before paper-passing, reassurance, room-emptying and the private conversation.

signal quiz_finished
signal step_started(index: int, step_id: StringName)
signal stage_direction(cue_id: StringName, direction: String)

const DialoguePanel = preload("res://scripts/dialogue_panel.gd")
const Typewriter = preload("res://scripts/text_type.gd")

enum Phase { WAITING, CUE, DIALOGUE, INTERRUPTION, COMPLETE, TRANSITION }
## Narrative requirements, not a second world-state authority.
enum RealityRequirement { NORMAL, MANIFESTED }

# Wording, punctuation, attribution and order remain verbatim. Stage directions
# are silent staging cues, never invented narration or substitute animation/audio.
# Layout and hold values are explicit presentation choices, not text-driven resizing.
const STEPS: Array[Dictionary] = [
	{"id": &"answer_erasure", "kind": &"cue", "hold": 0.8, "direction": "He writes a line. Reads it. Erases it."},
	{"id": &"knew_yesterday", "speaker": "Albert", "text": "I knew this yesterday.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"reviewed_twice", "speaker": "Albert", "text": "I went over it twice.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"did_you", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "Did you?", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.2},
	{"id": &"pencil_tapping_stops", "kind": &"cue", "hold": 0.45, "direction": "[SFX: Pencil tapping. It stops.]"},
	{"id": &"observe_classmates", "kind": &"cue", "hold": 1.1, "direction": "Across the room, Liezel is writing steadily. Jules chews his pencil, frowns, then keeps going. Neither of them looks stuck. Albert looks back at his page."},
	{"id": &"everyone_writing", "speaker": "Albert", "text": "F*ck, everyone else is writing.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"losing_race", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "You’re losing the race.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.6},
	{"id": &"fifteen_minutes", "speaker": "Instructor", "text": "Fifteen minutes.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"slow", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "So f*cking slow.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.3},
	{"id": &"fifteen_reaction", "speaker": "Albert", "text": "Fifteen?!", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"ten_second_ago", "speaker": "Albert", "text": "That was ten a second ago.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"excuses", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "Excuses.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.2},
	{"id": &"answer_paper", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "You wouldn’t be questioning it if you actually answer the f*cking paper.", "layout": DialoguePanel.Layout.COMPACT, "hold": 3.0},
	{"id": &"question_seven", "kind": &"cue", "hold": 1.0, "direction": "He flips to the next page. Question 7 has been erased so many times the paper has turned gray. He tries once more, pushes the eraser through the page, and stops."},
	{"id": &"five_minutes", "speaker": "Instructor", "text": "Five minutes.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"silence", "speaker": "Albert", "text": "...", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"write_something", "speaker": "Albert", "text": "Just write something.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"die", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "Die.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.3},
	{"id": &"uncertain_answer", "kind": &"cue", "hold": 0.8, "direction": "He writes something. He doesn’t believe it."},
	{"id": &"time_called", "speaker": "Instructor", "text": "Time’s up.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"times_up", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "times. Up.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.2},
	{"id": &"pencils_down", "speaker": "Instructor", "text": "Pencils down.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"fraud", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "Fraud.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.2},
	{"id": &"pass_papers", "speaker": "Instructor", "text": "Pass your papers to the front.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"imposter", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "Imposter.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.2},
]

@export_node_path("Control") var panel_path: NodePath = ^"../StoryLayer/DialoguePanel"
@export_node_path("CharacterBody2D") var player_path: NodePath = ^"../Foundation/Player"
@export var intrusion_material: ShaderMaterial
## Removes text displacement; keeps the distinct static color and identical input gates.
@export var reduced_motion: bool = false
@export_range(0.0, 0.7, 0.05) var distortion_seconds: float = 0.45

@onready var panel: DialoguePanel = get_node(panel_path)
@onready var body: Typewriter = panel.get_node("Margin/Content/Body")
@onready var player: CharacterBody2D = get_node(player_path)
@onready var reality: Node = get_node("../RealityPresentation")

var phase: Phase = Phase.WAITING
var step_index: int = -1
var hold_remaining: float = 0.0
var _effect_elapsed: float = 0.0
var _held_keys: Dictionary = {}
var _mouse_held: bool = false
var _wait_for_release: bool = false
var _last_accept_frame: int = -1
var _normal_color: Color
var _normal_material: Material
var _step_pending: bool = false
var _required_reality: int = 0
var _step_reality_cue: StringName
var _waiting_for_busy_transition: bool = false


func _ready() -> void:
	_normal_color = body.get_theme_color("font_color")
	_normal_material = body.material
	reality.transition_finished.connect(_on_step_reality_finished)
	set_process_input(false)
	set_process(false)
	get_window().focus_exited.connect(_clear_held_inputs)


func _on_opening_finished() -> void:
	if phase != Phase.WAITING:
		return
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	body.set_process_unhandled_key_input(false)
	set_process(true)
	set_process_input(true)
	_clear_held_inputs()
	_next_step()


func _next_step() -> void:
	if _step_pending:
		return
	_restore_text()
	body.interrupt_reveal()
	body.clear_line()
	step_index += 1
	var steps: Array[Dictionary] = sequence_steps()
	var requirement: int = steps[step_index].get("reality", RealityRequirement.NORMAL) if step_index < steps.size() else RealityRequirement.NORMAL
	_required_reality = reality.State.MANIFESTED if requirement == RealityRequirement.MANIFESTED else reality.State.NORMAL
	_step_reality_cue = StringName("%s:%d" % [name, step_index])
	_step_pending = true
	if _request_step_reality():
		return
	_step_pending = false
	_present_step()


## No text, cue timer or reading hold starts until the requested world is ready.
func _request_step_reality() -> bool:
	if reality.state == _required_reality:
		return false
	phase = Phase.TRANSITION
	panel.hide()
	_clear_held_inputs()
	_waiting_for_busy_transition = reality.state in [reality.State.GLITCH_IN, reality.State.GLITCH_OUT]
	if not _waiting_for_busy_transition:
		var accepted: bool = reality.request_manifestation(_step_reality_cue) if _required_reality == reality.State.MANIFESTED else reality.request_normal(_step_reality_cue)
		if not accepted:
			push_error("Scene 01 reality request rejected: " + String(_step_reality_cue))
	return true


func _on_step_reality_finished(_target: int, cue: StringName) -> void:
	if not _step_pending or (cue != _step_reality_cue and not _waiting_for_busy_transition):
		return
	_waiting_for_busy_transition = false
	if _request_step_reality():
		return
	_step_pending = false
	_present_step()


func _present_step() -> void:
	_clear_held_inputs()
	if step_index >= sequence_steps().size():
		phase = Phase.COMPLETE
		panel.hide()
		set_process(false)
		set_process_input(false)
		quiz_finished.emit()
		return
	var entry: Dictionary = sequence_steps()[step_index]
	step_started.emit(step_index, entry["id"])
	var kind: StringName = entry.get("kind", &"dialogue")
	hold_remaining = float(entry.get("hold", 0.0))
	_effect_elapsed = 0.0
	if kind == &"cue":
		phase = Phase.CUE
		panel.hide()
		stage_direction.emit(entry["id"], entry["direction"])
		return
	# Identity, panel styling and required world reality are independent metadata.
	panel.configure_presentation(
		entry.get("style", DialoguePanel.DialogueStyle.REALITY),
		String(entry.get("speaker", "")), entry["layout"])
	panel.hint.text = "E / Space / Click"
	panel.show()
	# The supplied font lacks U+2019. Keep source text above intact and display
	# its native straight apostrophe, as the shared typewriter does for ellipses.
	body.present_line(display_text(String(entry["text"])))
	if kind == &"intrusive":
		phase = Phase.INTERRUPTION
		# Muted rose preserves the intrusion identity with contrast on the black skin.
		body.add_theme_color_override("font_color", Color("#e0a3af"))
		body.material = intrusion_material
		body.reveal_line()
		panel.hint.hide()
	else:
		phase = Phase.DIALOGUE
		panel.hint.show()


func _process(delta: float) -> void:
	if phase == Phase.CUE:
		hold_remaining = maxf(0.0, hold_remaining - delta)
		if hold_remaining <= 0.0:
			_next_step()
		return
	if phase == Phase.INTERRUPTION:
		_effect_elapsed += delta
		var amount: float = 0.0
		if not reduced_motion and distortion_seconds > 0.0:
			amount = maxf(0.0, 1.0 - _effect_elapsed / distortion_seconds)
		intrusion_material.set_shader_parameter("amount", amount)
		intrusion_material.set_shader_parameter("effect_time", _effect_elapsed)
		if hold_remaining > 0.0:
			hold_remaining = maxf(0.0, hold_remaining - delta)
			if hold_remaining <= 0.0:
				# Drop every press from the mandatory interval; never queue an advance.
				_wait_for_release = true
				_last_accept_frame = Engine.get_process_frames() + 1
	if _wait_for_release and Engine.get_process_frames() > _last_accept_frame:
		if _held_keys.is_empty() and not _mouse_held and not Input.is_action_pressed(&"dialogue_advance") and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_wait_for_release = false
	if phase == Phase.INTERRUPTION:
		panel.hint.visible = hold_remaining <= 0.0 and not _wait_for_release


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
		if get_viewport().get_visible_rect().has_point(event.position):
			_advance_or_reveal()


func _advance_or_reveal() -> void:
	if phase not in [Phase.DIALOGUE, Phase.INTERRUPTION] or _wait_for_release or hold_remaining > 0.0:
		return
	var frame: int = Engine.get_process_frames()
	if frame <= _last_accept_frame:
		return
	_last_accept_frame = frame
	if body.is_typing:
		body.reveal_line()
		return
	panel.notify_accepted_advance(_has_following_dialogue())
	_next_step()


func _has_following_dialogue() -> bool:
	var steps: Array[Dictionary] = sequence_steps()
	for i in range(step_index+1,steps.size()):
		if steps[i].has("text"): return true
	# The quiz explicitly hands off to dismissal dialogue; other closures stay silent.
	return name == &"QuizSequence"


func _restore_text() -> void:
	panel.world = DialoguePanel.World.REAL
	panel.show_nameplate = true
	body.material = _normal_material
	body.add_theme_color_override("font_color", _normal_color)


func sequence_steps() -> Array[Dictionary]:
	return STEPS


func display_text(source: String) -> String:
	return source.replace("’", "'")


func _clear_held_inputs() -> void:
	_held_keys.clear()
	_mouse_held = false
	_wait_for_release = true
	_last_accept_frame = Engine.get_process_frames() + 1


func _exit_tree() -> void:
	if is_instance_valid(body):
		_restore_text()
