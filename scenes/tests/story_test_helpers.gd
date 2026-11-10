extends Node
## Shared story-test assertions, scene loading and input; no numerical state dependency.

const BEDROOM: String = "res://scenes/story/bedroom_story.tscn"

var checks: int = 0
var failures: int = 0

func _ready() -> void:
	_run.call_deferred()

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("Story test: " + label)

func _load_scene(path: String) -> Node:
	_check(get_tree().change_scene_to_file(path) == OK, "scene load requested: " + path)
	await get_tree().scene_changed
	await get_tree().process_frame
	await get_tree().process_frame
	return get_tree().current_scene

func _key(code: Key, echo: bool = false) -> void:
	var press := InputEventKey.new()
	press.physical_keycode = code
	press.keycode = code
	press.pressed = true
	press.echo = echo
	Input.parse_input_event(press)

func _release(code: Key) -> void:
	var release := InputEventKey.new()
	release.physical_keycode = code
	release.keycode = code
	Input.parse_input_event(release)

func _press(code: Key) -> void:
	await get_tree().process_frame
	_key(code)
	await get_tree().process_frame
	_release(code)
	await get_tree().process_frame

func _reach_choices(story: Node) -> void:
	await get_tree().create_timer(0.4).timeout
	for step in range(6):
		await _press(KEY_E)
	await get_tree().create_timer(0.4).timeout
	await _press(KEY_SPACE)
	await _press(KEY_SPACE)
	for step in range(3):
		await _press(KEY_E)
	_check(story.stage == &"phone" and story.phone.is_choosing(), "waking/reaction/phone reaches choices")

func _finish_story(story: Node, branch: int) -> void:
	var limit: int = 25
	while story.stage != &"exploration" and limit > 0:
		await _press(KEY_E)
		limit -= 1
	_check(story.stage == &"exploration" and story.selected_branch == branch, "phone branch and reflection finish")
	_check(GameState.get_flag("bedroom_intro_completed") == true, "completion flag after final reflection")
	_check(story.player.is_physics_processing() and not story.interactions.suspended, "exploration control restored")

func _run() -> void:
	pass

func _visible_hud_frames(room: Node) -> Array[Control]:
	var frames: Array[Control] = []
	for child: Node in room.get_children():
		if child is CanvasLayer:
			var frame: Control = child.get_node_or_null("Screen/Frame") as Control
			if frame != null and frame.is_visible_in_tree() and frame.modulate.a > 0.01:
				frames.append(frame)
	return frames
