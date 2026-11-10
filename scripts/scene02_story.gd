extends Node2D
## Owns only settled location handoff and the full Scene 02 completion boundary.
signal scene_completed
const EXTERIOR = preload("res://scenes/story/scene02_exterior.tscn")
@export var reduced_motion: bool = false
@export_range(0.0, 1.0, 0.05) var cover_seconds: float = 0.45
@export_range(0.0, 1.0, 0.05) var uncover_seconds: float = 0.45
var gate_walk_active: bool=false
var departure_position:=Vector2.ZERO
var hallway_finished: bool = false
var exterior_entered: bool = false
var completed: bool = false
var cancelled: bool = false
var completion_count: int = 0
var handoff_count: int = 0
var hallway_trace: Array[Dictionary] = []
var traversal_trace: Array[Dictionary] = []
var handoff_trace: Dictionary = {}
var objective_history: Array[StringName] = []
var _generation: int = 0
var _fade: Tween
@onready var location: Node2D = $Location/HallwayStory
@onready var cover: ColorRect = $LocationCover/Cover

func _ready() -> void:
	location.get_node("Player").position=Vector2(3570,405)
	location.get_node("Player").animated_sprite.facing_sector=2
	location.get_node("Narrative").story_reduced_motion = reduced_motion
	location.get_node("Narrative").reduced_motion = reduced_motion
	location.get_node("RealityGlitch").reduced_motion = reduced_motion
	location.hallway_segment_completed.connect(_on_hallway_finished)

func _on_hallway_finished() -> void:
	if hallway_finished or cancelled: return
	var narrative: Node = location.get_node("Narrative")
	if narrative.stage != narrative.Stage.DONE or narrative.completion_count != 1 or narrative.phase != narrative.Phase.COMPLETE or narrative.body.is_typing or narrative.panel.visible or narrative.reality.state != narrative.reality.State.NORMAL:
		push_error("Scene 02 handoff refused: Hallway presentation has not settled.")
		return
	hallway_finished = true
	hallway_trace.assign(narrative.event_trace)
	traversal_trace.assign(narrative.traversal_trace)
	objective_history.assign(location.get_node("GameplayUI").completed_ids)
	handoff_trace = {"clock_before": GameClock.get_minutes(), "glitches": location.get_node("TransitionAudio").glitch_count, "music_starts_before": AudioDirector.music_starts, "music_position_before": AudioDirector.music.get_playback_position()}
	location.get_node("Player").set_control(true)
	location.get_node("StoryLayer/Completion").hide()
	_handoff.call_deferred()

func _handoff() -> void:
	if cancelled or not is_inside_tree(): return
	_generation += 1
	var generation: int = _generation
	location.process_mode=Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(.65,false).timeout
	cover.show()
	cover.color.a = 0.0
	_fade = create_tween()
	_fade.tween_property(cover, "color:a", 1.0, cover_seconds)
	await _fade.finished
	if not _valid(generation): return
	await RenderingServer.frame_post_draw
	if not _valid(generation): return
	handoff_trace["covered_swap"]=cover.color.a==1.0
	for view in location.find_children("*","SubViewport",true,false):view.render_target_update_mode=SubViewport.UPDATE_DISABLED
	await RenderingServer.frame_post_draw
	# Dialogue has closed, and its signal stack unwound before removing this branch.
	location.process_mode = Node.PROCESS_MODE_DISABLED
	$Location.remove_child(location)
	location.queue_free()
	location = EXTERIOR.instantiate()
	location.get_node("Scene02Narrative").autostart = false
	location.get_node("Scene02Narrative").reduced_motion = reduced_motion
	location.get_node("GameplayUI").completed_ids.assign(objective_history)
	location.exterior_segment_completed.connect(_on_exterior_finished)
	$Location.add_child(location)
	var frozen: Array[Node]=[]
	for node in [location]+location.find_children("*","Node",true,false):
		if node.is_physics_processing():
			frozen.append(node)
			node.set_physics_process(false)
	location.get_node("Player/Camera2D").force_update_scroll()
	exterior_entered = true
	handoff_count += 1
	handoff_trace["clock_after"] = GameClock.get_minutes()
	handoff_trace["music_starts_after"] = AudioDirector.music_starts
	handoff_trace["music_position_after"] = AudioDirector.music.get_playback_position()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	location.process_mode=Node.PROCESS_MODE_DISABLED
	if not _valid(generation): return
	_fade = create_tween()
	_fade.tween_property(cover, "color:a", 0.0, uncover_seconds)
	await _fade.finished
	if not _valid(generation): return
	cover.hide()
	for node in frozen:
		if is_instance_valid(node):node.set_physics_process(true)
	location.process_mode=Node.PROCESS_MODE_INHERIT
	location.get_node("Scene02Narrative").begin_sequence()

func _on_exterior_finished() -> void:
	if completed or cancelled or not hallway_finished or not exterior_entered: return
	var narrative: Node = location.get_node("Scene02Narrative")
	if not narrative.completed or narrative.completion_count != 1 or narrative.phase != narrative.Phase.COMPLETE or narrative.body.is_typing or narrative.panel.visible or narrative._step_pending or narrative.reality.state != narrative.reality.State.NORMAL: return
	location.get_node("GameplayUI").finish_objectives()
	departure_position=location.get_node("Player").position
	completed=true
	completion_count+=1
	scene_completed.emit()
	if get_tree().current_scene==self:
		await get_tree().create_timer(.65,false).timeout
		if not cancelled:location.begin_guardhouse()

func _valid(generation: int) -> bool:
	return generation == _generation and not cancelled and is_inside_tree()

func cancel_sequence() -> void:
	if completed or cancelled: return
	cancelled = true
	_generation += 1
	if is_instance_valid(_fade): _fade.kill()
	cover.hide()
	if is_instance_valid(location):
		var runner=location.get_node("Scene02Narrative") if exterior_entered else location.get_node("Narrative")
		runner.cancel_sequence()
		location.get_node("Player").set_control(false)

func _input(event: InputEvent) -> void:
	if cover.visible and (event is InputEventKey or event is InputEventMouseButton):
		get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	_generation += 1
	if is_instance_valid(_fade): _fade.kill()
