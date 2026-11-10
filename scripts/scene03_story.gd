extends "res://scripts/scene03_exterior_foundation.gd"
signal scene_completed
signal pedestrian_exit_crossed
var gate_exited: bool=false
var objective_history: Array[Dictionary]=[]
@export var reduced_motion: bool=false
@export var scene02_phase: bool=false
var approaching_gate: bool=false
var completed: bool=false
var completion_count: int=0
var cancelled: bool=false

func _ready() -> void:
	development_tools_enabled=false
	development_exploration=false
	super._ready()
	player.set_control(false)
	$Narrative.reduced_motion=reduced_motion
	$RealityGlitch.reduced_motion=reduced_motion
	diagnostic.hide()
	var compact:=FontVariation.new()
	compact.base_font=load("res://assets/fonts/Pixel handwriting_regular.ttf")
	compact.spacing_top=-26
	compact.spacing_bottom=-20
	prompt.add_theme_font_override("font",compact)
	prompt.add_theme_font_size_override("font_size",26)
	prompt.add_theme_constant_override("line_spacing",0)
	if scene02_phase:
		objective.hide()
		$BoardInteraction.suspended=true
		$Narrative.set_process_input(false)
	$GateExit.body_entered.connect(_on_gate_exit_body)

func _physics_process(delta: float) -> void:
	if scene02_phase:
		prompt.hide()
		$GuardMarker.hide()
		return
	super._physics_process(delta)
	diagnostic.hide()
	if approaching_gate and player.position.distance_to(guard.position)<160:
		approaching_gate=false
		_show_objective("Talk to Mang Arnel")
	$GuardMarker.position=guard.position+Vector2(0,-48)
	$GuardMarker.visible=not encounter_pending and not canonical_encounter_completed and player.position.distance_to(guard.position)<320
	if canonical_encounter_completed and not gate_exited and player.global_position.y>=1490:
		_on_gate_exit_body(player)
	if prompt.visible:
		prompt.text="[E / Space / Click] Talk to Mang Arnel"
		prompt.size=prompt.get_combined_minimum_size()
		var anchor: Vector2=guard.get_global_transform_with_canvas().origin
		prompt.position=Vector2(anchor.x-prompt.size.x*.5,anchor.y-126.0-prompt.size.y).clamp(Vector2(16,160),Vector2(1264,944)-prompt.size).round()
	if completed or cancelled or $StoryLayer/DialoguePanel.visible: prompt.hide()

func resolve_encounter(success: bool) -> void:
	if not encounter_pending or canonical_encounter_completed: return
	encounter_pending=false
	if not success: return
	canonical_encounter_completed=true
	_update_gate()
	_show_objective("Head through the school gate")
	gate_conversation_completed.emit()

func _show_objective(title: String) -> void:
	if scene02_phase:return
	if title=="Head home": title="Head through the school gate"
	if not objective_history.is_empty() and objective_history[-1].title==title: return
	objective_history.append({"title":title,"position":player.position,"clock":GameClock.get_minutes()})
	super._show_objective(title)

func _on_gate_exit_body(body: Node2D) -> void:
	if body!=player or gate_exited or not canonical_encounter_completed or cancelled: return
	gate_exited=true
	$ProgressionGate/CollisionShape2D.set_deferred("disabled",false)
	_show_objective("Continue down the road")
	pedestrian_exit_crossed.emit()

func finish_scene() -> void:
	if completed or cancelled or not canonical_encounter_completed: return
	var n=$Narrative
	if not n.road or n.phase!=n.Phase.COMPLETE or n.body.is_typing or $RealityPresentation.state!=0: return
	completed=true
	completion_count+=1
	objective.finish_and_hide()
	scene_completed.emit()

func cancel_sequence() -> void:
	if cancelled: return
	cancelled=true
	$Narrative.cancel_sequence()
	$BoardInteraction.suspended=true
	prompt.hide()

## Supported replay boundary: settle scene-local presentation before reloading.
func restart_scene() -> void:
	cancel_sequence()
	_restart_settled.call_deferred()

func _restart_settled() -> void:
	while $RealityPresentation.state in [1,3]:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if is_inside_tree() and get_tree().current_scene==self:
		get_tree().call_deferred("reload_current_scene")

func begin_guardhouse() -> void:
	if not scene02_phase: return
	scene02_phase=false
	approaching_gate=true
	$GameplayUI.hide()
	$ExteriorAudio.finish_walkway_mix()
	player.set_physics_process(true)
	player.set_control(false)
	_show_objective("Go to the main gate")
