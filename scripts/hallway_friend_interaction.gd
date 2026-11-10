extends Node
## World activation adapter; dialogue and reality transitions retain their own input guards.
@export var target_paths: Array[NodePath] = []
@onready var narrative: Node = get_node("../Narrative")
@onready var player: CharacterBody2D = get_node("../Player")
@onready var prompt: Label = get_node("../StoryLayer/InteractionPrompt")
var selected: Node2D
var targets: Array[Node2D] = []
var starts: int = 0

func _ready() -> void:
	for path in target_paths: targets.append(get_node(path))
	var compact:=FontVariation.new()
	compact.base_font=prompt.get_theme_font("font")
	compact.spacing_top=-26
	compact.spacing_bottom=-20
	prompt.add_theme_font_override("font",compact)
	prompt.add_theme_font_size_override("font_size",26)
	prompt.add_theme_constant_override("line_spacing",0)
	prompt.hide()

func _physics_process(_delta: float) -> void:
	selected = null
	var nearest: float = INF
	if not narrative.encounter_started:
		for target in targets:
			target.observe(player.global_position)
			var distance: float = player.global_position.distance_squared_to(target.global_position)
			if target.available() and distance < nearest:
				selected = target
				nearest = distance
	prompt.hide()
	if selected != null:
		prompt.text = "[E / Space / Click] Talk to " + selected.display_name
		_place_prompt(selected.screen_bounds())


func _place_prompt(bounds: Rect2) -> void:
	prompt.size = prompt.get_combined_minimum_size()
	var view: Rect2 = prompt.get_viewport_rect().grow(-16)
	prompt.position = Vector2(bounds.get_center().x - prompt.size.x * .5, bounds.position.y - prompt.size.y - 8).clamp(view.position, view.end - prompt.size).round()
	prompt.show()

func _unhandled_input(event: InputEvent) -> void:
	if selected==null: return
	if not preload("res://scripts/interaction_activation.gd").accepts(event,selected.screen_bounds(),prompt.get_global_rect()): return
	if not selected.available() or narrative.encounter_started: return
	get_viewport().set_input_as_handled()
	var target: Node2D = selected
	if not narrative.begin_encounter(): return
	starts += 1
	player.animated_sprite.update_motion(target.global_position - player.global_position, Vector2.ZERO)
	target.get_parent().face_direction(player.global_position - target.global_position)
	prompt.hide()
	selected = null
