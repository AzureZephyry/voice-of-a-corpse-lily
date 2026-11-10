extends Node2D
var unlocked: bool=false
@onready var host: Node=get_parent()
@onready var player: CharacterBody2D=get_node("../Foundation/Player")
@onready var prompt: Label=host.get_node("DismissalSequence").prompt
func _ready() -> void:
	set_physics_process(false)
func unlock() -> void:
	unlocked=true
	var compact:=FontVariation.new()
	compact.base_font=load("res://assets/fonts/Pixel handwriting_regular.ttf")
	compact.spacing_top=-26
	compact.spacing_bottom=-20
	prompt.add_theme_font_override("font",compact)
	prompt.add_theme_font_size_override("font_size",26)
	prompt.add_theme_constant_override("line_spacing",0)
	var flags: Array[bool]=[]
	host.get_node("DismissalSequence").objective.present("Exit the classroom",PackedStringArray(),flags)
	host.get_node("DismissalSequence").objective.show()
	$Marker.show()
	player.set_physics_process(true)
	set_physics_process(true)
func _physics_process(_delta: float) -> void:
	prompt.visible=unlocked and not host.get_node("StoryLayer/DialoguePanel").visible and player.global_position.distance_to(global_position)<=100
	if prompt.visible:
		prompt.text="[E / Space / Click] Exit classroom"
		prompt.size=prompt.get_combined_minimum_size()
		var anchor: Vector2=get_global_transform_with_canvas().origin
		prompt.position=(anchor-Vector2(prompt.size.x*.5,34)).clamp(Vector2(16,16),prompt.get_viewport_rect().size-Vector2(16,16)-prompt.size).round()
func _unhandled_input(event: InputEvent) -> void:
	if not unlocked or not prompt.visible or host.get_node("StoryLayer/DialoguePanel").visible: return
	var bounds: Rect2=get_global_transform_with_canvas()*Rect2(-78,-25,156,50)
	if not preload("res://scripts/interaction_activation.gd").accepts(event,bounds,prompt.get_global_rect()): return
	get_viewport().set_input_as_handled()
	unlocked=false
	prompt.hide();$Marker.hide()
	host._on_classroom_exit()
