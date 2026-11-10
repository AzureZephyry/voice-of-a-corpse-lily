extends "res://scripts/classroom_quiz.gd"
## Screenplay paragraphs 24–32. Reuses the quiz's dialogue and input gates.

signal dismissal_finished
signal instructor_requested
signal audio_cued(cue_id: StringName)

const DISMISSAL_STEPS: Array[Dictionary] = [
	{"id": &"paper_passing", "kind": &"cue", "hold": 1.2, "direction": "Albert passes his paper down the row. It looks very thin."},
	{"id": &"its_fine", "speaker": "Albert", "text": "It’s fine.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"is_it", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "Is it.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.2},
	{"id": &"pause", "kind": &"cue", "hold": 0.7, "direction": "Pause."},
	{"id": &"just_quiz", "speaker": "Albert", "text": "It’s just a quiz.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"just_excuses", "kind": &"intrusive", "reality": RealityRequirement.MANIFESTED, "style": DialoguePanel.DialogueStyle.MANIFESTATION, "speaker": "???", "text": "Just excuses after excuses.", "layout": DialoguePanel.Layout.COMPACT, "hold": 1.8},
	{"id": &"reassurance", "kind": &"cue", "hold": 1.2, "direction": "He says it twice more in his head, as if the second time will be the one that works."},
	{"id": &"room_empties", "kind": &"cue", "hold": 999.0, "direction": "The room empties. Albert stays seated. The instructor is wiping the board, and the squeak of the eraser fills the quiet."},
	{"id": &"just_say_it", "speaker": "Albert", "text": "Just say it.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"need_help", "speaker": "Albert", "text": "Sir, I need help. That’s all.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"harder_things", "speaker": "Albert", "text": "You’ve said harder things.", "layout": DialoguePanel.Layout.COMPACT},
	{"id": &"pause_before_standing", "kind": &"cue", "hold": 0.8, "direction": "Pause."},
	{"id": &"have_i", "speaker": "Albert", "text": "Have I?", "layout": DialoguePanel.Layout.COMPACT},
]

@export var fade_seconds: float = 1.0
@export var empty_room_hold_seconds: float = 0.6
@onready var blackout: ColorRect = get_node("../RevealLayer/Blackout")
@onready var cast: Node2D = get_node("../Foundation/NormalNPCs")
@onready var objective: Label = get_node("../StoryLayer/InstructorObjective")
@onready var prompt: Label = get_node("../StoryLayer/InstructorPrompt")
@onready var marker: Node2D = get_node("../InstructorMarker")
@onready var target: Node2D = get_node("../InstructorInteraction")

var exploration_active: bool = false
var interaction_suspended: bool = false
var _interaction_held: bool = true
var _fade: Tween

func sequence_steps() -> Array[Dictionary]:
	return DISMISSAL_STEPS

func _on_stage_direction(cue_id: StringName, _direction: String) -> void:
	if cue_id == &"paper_passing":
		audio_cued.emit(&"papers_chairs_voices")
	elif cue_id == &"room_empties":
		_empty_room()

func _empty_room() -> void:
	blackout.color.a = 0.0
	blackout.show()
	_fade = create_tween()
	_fade.tween_property(blackout, "color:a", 1.0, fade_seconds)
	await _fade.finished
	for npc in cast.get_children():
		if npc.name != &"Professor":
			npc.hide()
	get_node("../ClockTicking").stop()
	audio_cued.emit(&"board_eraser")
	await get_tree().create_timer(empty_room_hold_seconds).timeout
	_fade = create_tween()
	_fade.tween_property(blackout, "color:a", 0.0, fade_seconds)
	await _fade.finished
	blackout.hide()
	hold_remaining = 0.0

func _on_sequence_finished() -> void:
	# Step out into the adjacent aisle using the existing physical body.
	# Furniture geometry and the approved seated anchor remain unchanged.
	for frame in 32:
		await get_tree().physics_frame
		var before := player.position
		player.move_and_collide(Vector2(150.0 * get_physics_process_delta_time(), 0))
		player.get_node("AnimatedSprite2D").update_motion(Vector2.RIGHT, player.position - before)
	player.get_node("AnimatedSprite2D").facing_sector = 2
	player.get_node("AnimatedSprite2D").show_idle()
	var compact:=FontVariation.new()
	compact.base_font=load("res://assets/fonts/Pixel handwriting_regular.ttf")
	compact.spacing_top=-26
	compact.spacing_bottom=-20
	prompt.add_theme_font_override("font",compact)
	prompt.add_theme_font_size_override("font_size",26)
	prompt.text="[E / Space / Click] Talk to your instructor"
	var completed: Array[bool] = []
	objective.present("Talk to your instructor", PackedStringArray(), completed)
	objective.show()
	marker.show()
	get_node("../ProfessorFootprint/Feet").set_deferred("disabled", false)
	exploration_active = true
	set_process(true)
	set_process_input(true)
	dismissal_finished.emit()

func _process(delta: float) -> void:
	if not exploration_active:
		super._process(delta)
		return
	var busy: bool = interaction_suspended or panel.visible or blackout.visible
	player.set_physics_process(not busy)
	if busy:
		player.velocity = Vector2.ZERO
	target.observe(player.global_position)
	prompt.visible = not busy and target.in_range
	if prompt.visible:
		var bounds: Rect2=target.screen_bounds()
		prompt.size=prompt.get_combined_minimum_size()
		prompt.position=(Vector2(bounds.get_center().x,bounds.position.y-8)-Vector2(prompt.size.x*.5,prompt.size.y)).clamp(Vector2(16,16),prompt.get_viewport_rect().size-Vector2(16,16)-prompt.size).round()
	# Follow the existing contextual-marker convention: prompt replaces the diamond nearby.
	marker.visible = not busy and not target.in_range
	if not Input.is_action_pressed(&"dialogue_advance"):
		_interaction_held = false

func _input(event: InputEvent) -> void:
	if not exploration_active:
		super._input(event)
		return
	return

func _exit_tree() -> void:
	if is_instance_valid(_fade):
		_fade.kill()
	super._exit_tree()

func _unhandled_input(event: InputEvent) -> void:
	if not exploration_active or interaction_suspended or not prompt.visible: return
	if preload("res://scripts/interaction_activation.gd").accepts(event,target.screen_bounds(),prompt.get_global_rect()):
		get_viewport().set_input_as_handled()
		instructor_requested.emit()
