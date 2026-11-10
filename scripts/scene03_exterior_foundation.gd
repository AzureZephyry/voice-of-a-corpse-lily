extends "res://scenes/environments/school_exterior/school_exterior_occlusion.gd"
## Foundation hooks only. No screenplay entries or narrative completion are installed.
signal encounter_requested
signal gate_conversation_completed
signal zone_changed(zone: StringName)
@export var development_tools_enabled: bool = true
@export var development_exploration: bool = false
var encounter_pending: bool = false
var encounter_requests: int = 0
var canonical_encounter_completed: bool = false
var road_test_access: bool = false
var zone: StringName = &"gate"
var _e_down: bool = false
@onready var player: CharacterBody2D = $Player
@onready var guard: CharacterBody2D = $MangArnel
@onready var prompt: Label = $FoundationUI/Prompt
@onready var diagnostic: Label = $FoundationUI/Diagnostic
@onready var objective: Label = $Objectives/Objective

func _ready() -> void:
	super._ready()
	road_test_access = OS.is_debug_build() and development_exploration
	_update_gate()
	_show_objective("Talk to Mang Arnel")

func _physics_process(_delta: float) -> void:
	var next: StringName = &"road" if player.position.y >= 1512.0 else &"gate"
	if next != zone:
		zone = next
		zone_changed.emit(zone)
	prompt.hide()
	if not $BoardInteraction.dialogue_open and not encounter_pending and not canonical_encounter_completed and $RealityPresentation.state in [0,2] and player.position.distance_to(guard.position) <= 64.0:
		prompt.text = "E / Space / Click\nTalk to Mang Arnel"
		prompt.size = prompt.get_combined_minimum_size()
		var center: Vector2 = guard.get_global_transform_with_canvas().origin
		prompt.position = (center-Vector2(prompt.size.x*.5,90)).clamp(Vector2(16,230),Vector2(1264,900)-prompt.size)
		prompt.show()
	diagnostic.text = "M05.2 DEVELOPMENT FOUNDATION — dialogue not implemented"
	if OS.is_debug_build() and development_tools_enabled:
		diagnostic.text += "\nR: environment test | M: reduced motion"
	if road_test_access: diagnostic.text += "\nDEV ROAD ACCESS — canonical conversation remains incomplete"
	elif encounter_pending: diagnostic.text += "\nEncounter requested; awaiting future canonical dialogue controller"

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_E and not event.pressed: _e_down=false

func _unhandled_input(event: InputEvent) -> void:
	var bounds: Rect2=guard.animated_sprite.get_global_transform_with_canvas()*Rect2(-16,-32,32,32)
	if not encounter_pending and not canonical_encounter_completed and not $BoardInteraction.dialogue_open and prompt.visible and preload("res://scripts/interaction_activation.gd").accepts(event,bounds,prompt.get_global_rect()):
		encounter_pending=true
		encounter_requests+=1
		encounter_requested.emit()
		get_viewport().set_input_as_handled()

	if OS.is_debug_build() and development_tools_enabled and event is InputEventKey and event.pressed and not event.echo and not $BoardInteraction.dialogue_open:
		if event.physical_keycode==KEY_R:
			if $RealityPresentation.state==0: $RealityPresentation.request_manifestation(&"scene03_development")
			elif $RealityPresentation.state==2: $RealityPresentation.request_normal(&"scene03_development")
		elif event.physical_keycode==KEY_M:
			if $RealityPresentation.state in [0,2]: $RealityGlitch.reduced_motion=not $RealityGlitch.reduced_motion

## Only a future canonical conversation controller calls this; E never does.
func resolve_encounter(success: bool) -> void:
	if not encounter_pending or canonical_encounter_completed: return
	encounter_pending=false
	if not success: return
	canonical_encounter_completed=true
	_update_gate()
	_show_objective("Head home")
	gate_conversation_completed.emit()

func _update_gate() -> void:
	$ProgressionGate/CollisionShape2D.set_deferred("disabled",canonical_encounter_completed or road_test_access)

func use_occlusion(mask_texture: Texture2D) -> void:
	occlusion_mask=mask_texture
	var image: Image=mask_texture.get_image()
	image.convert(Image.FORMAT_RGBA8)
	_mask=image.get_data()
	_mask_size=image.get_size()

func _show_objective(title: String) -> void:
	var flags: Array[bool] = [false]
	objective.present("Objective",PackedStringArray([title]),flags)
	objective.show()
