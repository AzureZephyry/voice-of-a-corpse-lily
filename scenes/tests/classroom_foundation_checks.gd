extends RefCounted
## Virtual sweeps use Albert's actual runtime feet shape without moving the actor.


static func inspect(scene: Node2D) -> Dictionary:
	var player: CharacterBody2D = scene.get_node("Player")
	var geometry: Node2D = scene.get_node("Classroom/Geometry")
	var checks: Array[Dictionary] = []
	for row: int in range(1, 5):
		for seat: int in range(1, 4):
			var name := "Row%dSeat%d" % [row, seat]
			var chair: StaticBody2D = geometry.get_node(name)
			checks.append(_sweep(player, name, chair.global_position + Vector2(80, 7), Vector2(-60, 0)))
	var probes := [
		["NorthWall", Vector2(960, 450), Vector2(0, -250)],
		["WestWall", Vector2(160, 570), Vector2(-200, 0)],
		["EastWall", Vector2(1180, 850), Vector2(140, 0)],
		["SouthWall", Vector2(900, 850), Vector2(0, 200)],
		["NorthCabinetLeft", Vector2(230, 460), Vector2(0, -100)],
		["NorthCabinetMiddle", Vector2(470, 460), Vector2(0, -100)],
		["NorthCabinetRight", Vector2(810, 460), Vector2(0, -100)],
		["WestCabinetUpper", Vector2(140, 480), Vector2(-100, 0)],
		["WestCabinetLower", Vector2(140, 850), Vector2(-100, 0)],
		["InstructorWorkstation", Vector2(940, 628), Vector2(100, 0)],
		["InstructorChair", Vector2(1160, 740), Vector2(0, -100)],
		["FrontEquipment", Vector2(1220, 720), Vector2(0, -100)],
	]
	for probe: Array in probes:
		checks.append(_sweep(player, probe[0], probe[1], probe[2]))
	var passed: bool = not player.test_move(player.global_transform, Vector2.ZERO)
	for check: Dictionary in checks:
		passed = passed and check.passed
	return {
		"passed": passed,
		"spawn_clear": not player.test_move(player.global_transform, Vector2.ZERO),
		"static_body_count": geometry.get_child_count(),
		"checks": checks,
	}


static func _sweep(player: CharacterBody2D, expected: String, start: Vector2, motion: Vector2) -> Dictionary:
	var collision := KinematicCollision2D.new()
	var hit: bool = player.test_move(Transform2D(0, start), motion, collision)
	var actual: String = str(collision.get_collider().name) if hit else "none"
	return {"expected": expected, "actual": actual, "passed": hit and actual == expected}


static func exercise(scene: Node2D) -> Dictionary:
	var player: CharacterBody2D = scene.get_node("Player")
	var camera: Camera2D = scene.get_node("FixedCamera")
	var steps: Array[Dictionary] = []
	var walking_frames: Array[int] = await _walk(player, "ui_right", 30)
	steps.append(_position_check("Exit seat into front aisle", player, Rect2(815, 626, 35, 4)))
	await _capture(scene, "classroom_preview_front_aisle.png")
	await _walk(player, "ui_down", 84)
	await _walk(player, "ui_left", 150)
	steps.append(_position_check("Traverse south aisle across seating rows", player, Rect2(430, 825, 55, 30)))
	await _capture(scene, "classroom_preview_south_aisle.png")
	await _walk(player, "ui_up", 48)
	steps.append(_position_check("Armchair blocks upward movement", player, Rect2(430, 821, 55, 2)))
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	steps.append({"name": "Blocked controller idles facing up", "passed": sprite.animation == &"idle_up"})
	await _walk(player, "ui_right", 150)
	await _walk(player, "ui_up", 78)
	await _walk(player, "ui_right", 84)
	steps.append(_position_check("Navigate to instructor; desk stops movement", player, Rect2(975, 600, 2, 70)))
	steps.append({"name": "Fixed camera", "passed": camera.get_screen_center_position().is_equal_approx(Vector2(640, 480))})
	steps.append({"name": "Walking frames advance", "passed": walking_frames.size() >= 3, "frames": walking_frames})
	await _capture(scene, "classroom_preview_instructor.png")
	var passed: bool = true
	for step: Dictionary in steps:
		passed = passed and step.passed
	return {"passed": passed, "steps": steps, "preview_only": scene.development_preview}


static func _walk(player: CharacterBody2D, action: String, frames: int) -> Array[int]:
	var sampled_frames: Array[int] = []
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	Input.action_press(action)
	for index: int in range(frames):
		await player.get_tree().physics_frame
		if String(sprite.animation).begins_with("walk_") and not sampled_frames.has(sprite.frame):
			sampled_frames.append(sprite.frame)
	Input.action_release(action)
	await player.get_tree().physics_frame
	await player.get_tree().physics_frame
	return sampled_frames


static func _position_check(label: String, player: CharacterBody2D, region: Rect2) -> Dictionary:
	return {"name": label, "passed": region.has_point(player.position), "position": [player.position.x, player.position.y]}


static func _capture(scene: Node2D, filename: String) -> void:
	await RenderingServer.frame_post_draw
	scene.get_viewport().get_texture().get_image().save_png("res://docs/classroom/screenshots/" + filename)
