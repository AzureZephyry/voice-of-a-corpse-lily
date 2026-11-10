extends Node
signal story_completed
const SCENES=[preload("res://scenes/story/classroom_opening.tscn"),preload("res://scenes/story/scene02_story.tscn"),preload("res://scenes/story/scene03_story.tscn"),preload("res://scenes/story/scene04_story.tscn")]
@export var reduced_motion: bool=false
var index: int=0
var active: Node
var busy: bool=false
var completed: bool=false
var handoffs: Array[Dictionary]=[]
func _ready() -> void:
	active=$Location/ClassroomOpening
	_connect_active()
func _connect_active() -> void:
	if "reduced_motion" in active:active.set("reduced_motion",reduced_motion)
	for node in active.find_children("*","Node",true,false):
		if "reduced_motion" in node:node.set("reduced_motion",reduced_motion)
	active.scene_completed.connect(_on_completed,CONNECT_ONE_SHOT)
func _on_completed() -> void:
	if busy or completed:return
	if index==3:
		completed=true
		story_completed.emit()
		return
	busy=true
	if index==1:_adopt_exterior.call_deferred()
	else:_handoff.call_deferred()
func _adopt_exterior() -> void:
	# Ownership changes, not the physical location. Let the completed checkbox read.
	await get_tree().create_timer(.65,false).timeout
	active=active.location
	index=2
	active.begin_guardhouse()
	_connect_active()
	handoffs.append({"from":2,"same_world":true,"clock":GameClock.get_minutes()})
	busy=false
func _handoff() -> void:
	var branch: Node=$Location.get_child(0)
	branch.process_mode=Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(.65,false).timeout
	$Cover/Black.modulate.a=0.0
	$Cover/Black.show()
	var fade=create_tween()
	fade.tween_property($Cover/Black,"modulate:a",1.0,.45)
	await fade.finished
	await RenderingServer.frame_post_draw
	for view in branch.find_children("*","SubViewport",true,false):view.render_target_update_mode=SubViewport.UPDATE_DISABLED
	await RenderingServer.frame_post_draw
	var record={"from":index+1,"clock_before":GameClock.get_minutes(),"music_before":AudioDirector.music.get_playback_position(),"covered_swap":$Cover/Black.modulate.a==1.0}
	$Location.remove_child(branch)
	branch.queue_free()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	index+=1
	active=SCENES[index].instantiate()
	if "reduced_motion" in active:active.set("reduced_motion",reduced_motion)
	$Location.add_child(active)
	var frozen: Array[Node]=[]
	for node in [active]+active.find_children("*","Node",true,false):
		if node.is_physics_processing():
			frozen.append(node)
			node.set_physics_process(false)
	_connect_active()
	var camera: Camera2D=get_viewport().get_camera_2d()
	if camera!=null:camera.force_update_scroll()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	active.process_mode=Node.PROCESS_MODE_DISABLED
	record.clock_after=GameClock.get_minutes()
	record.music_after=AudioDirector.music.get_playback_position()
	handoffs.append(record)
	fade=create_tween()
	fade.tween_property($Cover/Black,"modulate:a",0.0,.45)
	await fade.finished
	$Cover/Black.hide()
	for node in frozen:
		if is_instance_valid(node):node.set_physics_process(true)
	active.process_mode=Node.PROCESS_MODE_INHERIT
	busy=false
func _input(event: InputEvent) -> void:
	if busy and (event is InputEventKey or event is InputEventMouseButton):get_viewport().set_input_as_handled()
