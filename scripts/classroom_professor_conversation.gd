extends "res://scripts/classroom_quiz.gd"
## Time Called: actual speech, perceived pairs and the authored paper-focused ending.

signal conversation_started
signal manifestation_requested(pair_id: StringName)
signal conversation_finished

const CONVERSATION_STEPS: Array[Dictionary] = [
	{"id": &"sir", "channel": &"actual", "speaker": "Albert", "text": "Sir.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"yes_dimapilis", "channel": &"actual", "speaker": "Professor", "text": "Yes, Mr. Dimapilis?", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"hesitation", "kind": &"cue", "hold": 0.9, "direction": "Albert’s mouth opens. Nothing comes out for a moment."},
	{"id": &"dont_understand", "channel": &"actual", "speaker": "Albert", "text": "Sir... I don’t… actually understand anything.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"loops", "channel": &"actual", "speaker": "Albert", "text": "Loops. Everything, actually.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"embarrassing", "channel": &"thought", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "Embarrassing.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.3},
	{"id": &"takes_paper", "kind": &"cue", "hold": 0.9, "direction": "The instructor sets down the eraser and takes Albert’s paper from the top of the pile."},
	{"id": &"thank_you", "channel": &"actual", "speaker": "Professor", "text": "*sigh*..Thank you for telling me. Most people don’t.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"didnt_have_to", "channel": &"thought", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "Because they didn’t have to.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.8},
	{"id": &"come_sit", "channel": &"actual", "speaker": "Professor", "text": "Come, sit. Let’s look at it.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"points_with_pen", "kind": &"cue", "hold": 0.9, "direction": "He sets the paper between them and points with his pen."},
	{"id": &"second_loop", "channel": &"actual", "speaker": "Professor", "text": "Look at your second loop. You understood the idea. You just update the counter in the wrong place, so it never reaches the end.", "layout": DialoguePanel.Layout.STANDARD},
	{"id": &"trace_by_hand", "channel": &"actual", "speaker": "Professor", "text": "Trace it by hand, one step at a time. You’ll see it.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"common_first_month", "channel": &"actual", "speaker": "Professor", "text": "It’s a very common mistake in the first month.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"follows_pen", "kind": &"cue", "hold": 1.0, "direction": "Albert follows the pen. It does make sense. That is somehow worse."},
	{"id": &"review_chapter_two", "channel": &"actual", "speaker": "Professor", "text": "Review chapter two, then try again. You’ll get it.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"pair_one_clean", "channel": &"actual", "speaker": "Professor", "text": "It’s a very common mistake.", "layout": DialoguePanel.Layout.COMPACT},
]

# Heard text is Albert's perception, never substitute Professor speech.
const PERCEPTION_PAIRS: Array[Dictionary] = [
	{"id": &"pair_one", "enabled": true, "normal_ref": &"pair_one_clean", "trigger": &"after_advance", "return_ref": &"pair_two_clean", "actual_speaker": "Professor", "actual": "It’s a very common mistake.", "perceived_by": "Albert", "heard_speaker": "???", "heard_style": DialoguePanel.DialogueStyle.MANIFESTATION, "actual_style": DialoguePanel.DialogueStyle.REALITY, "heard": ["Common, Like everyone else.", "That’s all you’ll ever be."]},
	{"id": &"pair_two", "enabled": true, "normal_ref": &"pair_two_clean", "trigger": &"after_advance", "return_ref": &"earlier_next_time", "actual_speaker": "Professor", "actual": "You’ll get it, don’t worry.", "perceived_by": "Albert", "heard_speaker": "???", "heard_style": DialoguePanel.DialogueStyle.MANIFESTATION, "actual_style": DialoguePanel.DialogueStyle.REALITY, "heard": ["You should’ve gotten it already."]},
	# Paragraph 44 identifies an excerpt of paragraph 43, not a second delivery.
	{"id": &"pair_three", "enabled": true, "normal_ref": &"earlier_next_time", "clean_excerpt": "Come to me earlier next time.", "trigger": &"after_advance", "return_ref": &"thank_you_sir", "actual_speaker": "Professor", "actual": "And Albert, come to me earlier next time. Don’t wait until after the quiz.", "perceived_by": "Albert", "heard_speaker": "???", "heard_style": DialoguePanel.DialogueStyle.MANIFESTATION, "actual_style": DialoguePanel.DialogueStyle.REALITY, "heard": ["Too f*cking late.", "You waited too long."]},
]

const CLOSING_STEPS: Array[Dictionary] = [
	{"id": &"thank_you_sir", "channel": &"actual", "speaker": "Albert", "text": "....Thank you, sir.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"anytime", "channel": &"actual", "speaker": "Professor", "text": "Anytime.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"asshole", "channel": &"thought", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "A**hole.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.3},
	{"id": &"paper_focus", "kind": &"cue", "hold": 0.9, "direction": "Albert picks up his paper. The red mark at the top is smaller than he expected, and it is the only thing he can see."},
	# Verbatim source staging, presented as nameless narration, not Albert speech.
	{"id": &"paper_narration", "channel": &"narration", "speaker": "", "text": "Albert picks up his paper. The red mark at the top is smaller than he expected, and it is the only thing he can see.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"hand_narration", "channel": &"narration", "speaker": "", "text": "His hand is tight around the edge of the page.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"final_hold", "kind": &"cue", "hold": 1.2, "direction": "His hand is tight around the edge of the page."},
]

@onready var dismissal: Node = get_node("../DismissalSequence")
var completed_once: bool = false
var _active_pair: Dictionary = {}
var _heard_index: int = -1
var _waiting_target: int = -1
var _started_pairs: Dictionary = {}
var _showing_continuation: bool = false
var _continuation_ref: StringName
var _closing_sequence: bool = false
const RETURN_LINES: Dictionary = {
	&"pair_two_clean": {"speaker":"Professor", "text":"You’ll get it, don’t worry."},
	&"earlier_next_time": {"speaker":"Professor", "text":"And Albert, come to me earlier next time. Don’t wait until after the quiz."},
}

func _ready() -> void:
	super._ready()
	reality.transition_finished.connect(_on_reality_finished)
	body.authored_interruption_reached.connect(_on_authored_interruption)

func sequence_steps() -> Array[Dictionary]:
	return CLOSING_STEPS if _closing_sequence else CONVERSATION_STEPS

func _present_step() -> void:
	super._present_step()
	if _closing_sequence and step_index < CLOSING_STEPS.size() and CLOSING_STEPS[step_index].get("channel") == &"narration":
		panel.show_nameplate = false

func _on_instructor_requested() -> void:
	if phase != Phase.WAITING or not dismissal.exploration_active or dismissal.interaction_suspended:
		return
	dismissal.target.observe(player.global_position)
	if not dismissal.target.in_range:
		return
	dismissal.interaction_suspended = true
	dismissal.prompt.hide()
	dismissal.marker.hide()
	dismissal.objective.hide()
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	var albert: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	var professor: AnimatedSprite2D = get_node("../Foundation/NormalNPCs/Professor/AnimatedSprite2D")
	var direction: Vector2 = professor.global_position - player.global_position
	albert.update_motion(direction.normalized(), Vector2.ZERO)
	var sector: int = posmod(roundi((-direction).angle() / (PI / 4.0)), 8)
	professor.flip_h = sector in [3, 4, 5]
	professor.play(StringName("idle_" + albert.POSES[sector]))
	# Do not relocate either actor into the desk or instructor chair.
	_on_opening_finished()
	conversation_started.emit()

func _on_normal_segment_finished() -> void:
	if _closing_sequence:
		_finish_conversation()
	elif not _started_pairs.has(&"pair_one"):
		_begin_pair(PERCEPTION_PAIRS[0])

func _begin_pair(pair: Dictionary) -> bool:
	if not pair.enabled or _started_pairs.has(pair.id) or not _active_pair.is_empty() or reality.state != reality.State.NORMAL:
		return false
	_active_pair = pair
	_heard_index = -1
	_waiting_target = reality.State.MANIFESTED
	body.interrupt_reveal()
	panel.hide()
	phase = Phase.COMPLETE
	set_process(true)
	set_process_input(true)
	_clear_held_inputs()
	# Existing scene signal requests the single reality authority; audio keeps its hook.
	manifestation_requested.emit(pair.id)
	if reality.state == reality.State.NORMAL:
		# An invalid-context request is recoverable with a deliberate fresh advance.
		_active_pair = {}
		_waiting_target = -1
		_present_pair_line(pair.actual, pair.actual_speaker, false)
		return false
	_started_pairs[pair.id] = true
	return true

func _on_reality_finished(target: int, cue: StringName) -> void:
	if _active_pair.is_empty() or cue != _active_pair.id or target != _waiting_target:
		return
	_waiting_target = -1
	_clear_held_inputs()
	if target == reality.State.MANIFESTED:
		_next_step()
	else:
		_continuation_ref = _active_pair.return_ref
		_active_pair = {}
		if _continuation_ref == &"thank_you_sir":
			_closing_sequence = true
			step_index = -1
			super._next_step()
			return
		var line: Dictionary = RETURN_LINES[_continuation_ref]
		_showing_continuation = true
		_present_pair_line(line.text, line.speaker, false)

func _present_pair_line(text: String, speaker: String, perceived: bool) -> void:
	body.interrupt_reveal()
	_restore_text()
	panel.configure_presentation(DialoguePanel.DialogueStyle.MANIFESTATION if perceived else DialoguePanel.DialogueStyle.REALITY, speaker, DialoguePanel.Layout.COMPACT)
	panel.hint.text = "E / Space / Click"
	panel.hint.show()
	panel.show()
	# Keep the existing muted intrusion typography, without new displacement effects.
	if perceived:body.add_theme_color_override("font_color", Color("#e0a3af"))
	phase = Phase.DIALOGUE
	hold_remaining = 0.0
	body.present_line(text.replace("’", "'"))
	_clear_held_inputs()

func _advance_or_reveal() -> void:
	if _waiting_target >= 0 or completed_once:
		return
	super._advance_or_reveal()

func _has_following_dialogue() -> bool:
	if not _active_pair.is_empty() or _showing_continuation: return true
	if not _closing_sequence: return true
	return super._has_following_dialogue()

func _next_step() -> void:
	if not _active_pair.is_empty():
		_heard_index += 1
		if _heard_index < _active_pair.heard.size():
			_present_pair_line(_active_pair.heard[_heard_index], _active_pair.heard_speaker, true)
		else:
			body.interrupt_reveal()
			panel.hide()
			phase = Phase.COMPLETE
			_waiting_target = reality.State.NORMAL
			_clear_held_inputs()
			reality.request_normal(_active_pair.id)
		return
	if _showing_continuation:
		for pair: Dictionary in PERCEPTION_PAIRS:
			if pair.normal_ref == _continuation_ref:
				_showing_continuation = false
				if not _begin_pair(pair): _showing_continuation = true
				return
		return
	super._next_step()

func _on_authored_interruption(event_id: StringName, _shown: int) -> void:
	# No character index is invented for pair_one: its source transition follows
	# the completed clean passage. Later authored metadata may select this hook.
	for pair: Dictionary in PERCEPTION_PAIRS:
		if pair.id == event_id and pair.enabled and pair.trigger == &"character" and step_index >= 0 and step_index < CONVERSATION_STEPS.size() and CONVERSATION_STEPS[step_index].id == pair.normal_ref:
			_begin_pair(pair)
			return

func _finish_conversation() -> void:
	if completed_once: return
	completed_once = true
	_restore_text()
	body.clear_line()
	panel.hide()
	set_process(false)
	set_process_input(false)
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	# A deliberate completed-scene hold, not another proximity interaction.
	dismissal.interaction_suspended = true
	dismissal.set_process(false)
	dismissal.set_process_input(false)
	dismissal.target.finish(true)
	dismissal.prompt.hide()
	dismissal.marker.hide()
	var completed: Array[bool] = [true]
	dismissal.objective.present("Scene 01 complete", PackedStringArray(["Talk to your instructor"]), completed)
	dismissal.objective.show()
	conversation_finished.emit()
