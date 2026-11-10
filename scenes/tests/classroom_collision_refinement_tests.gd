extends RefCounted
## Test-only fixtures: reposition the live actor, then drive its original controller.

const OUT := "res://docs/classroom/collision_refinement/"
const CASES := [
	["rear_upper", Vector2(-30, 30), Vector2.RIGHT],
	["rear_seat", Vector2(-30, 76), Vector2.RIGHT],
	["rear_support", Vector2(-30, 110), Vector2.RIGHT],
	["front_support", Vector2(108, 110), Vector2.LEFT],
	["north_seat", Vector2(46, 24), Vector2.DOWN],
	["south_support", Vector2(46, 156), Vector2.UP],
	["front_seat", Vector2(108, 57), Vector2.LEFT],
	["front_writing_arm", Vector2(108, 96), Vector2.LEFT],
	["northwest", Vector2(-26, 20), Vector2(1, 1)],
	["northeast", Vector2(108, 70), Vector2(-1, 1)],
	["southwest", Vector2(-26, 150), Vector2(1, -1)],
	["southeast", Vector2(108, 150), Vector2(-1, -1)],
]


static func run_row(scene: Node2D, row: int, mode: String) -> Dictionary:
	var p: CharacterBody2D = scene.get_node("Player")
	var was_processing := p.is_physics_processing()
	p.set_physics_process(true) # Foundation fixture only; restored before return.
	var results: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	for seat: int in range(1, 4):
		var chair: StaticBody2D = scene.get_node("Classroom/Geometry/Row%dSeat%d" % [row, seat])
		var origin := chair.position - Vector2(40, 111)
		for probe: Array in CASES:
			p.position = origin + probe[1]
			p.velocity = Vector2.ZERO
			await scene.get_tree().physics_frame
			await scene.get_tree().physics_frame
			var start_clear := not p.test_move(p.global_transform, Vector2.ZERO)
			var collision := KinematicCollision2D.new()
			var sweep_hit := p.test_move(p.global_transform, probe[2].normalized() * 70, collision)
			var sweep_ok: bool = sweep_hit and collision.get_collider() == chair
			_press(probe[2])
			var contacted := false
			var jitter := false
			var previous := p.position
			for frame: int in range(20):
				await scene.get_tree().physics_frame
				for index: int in range(p.get_slide_collision_count()):
					contacted = contacted or p.get_slide_collision(index).get_collider() == chair
				jitter = jitter or (p.position - previous).dot(probe[2].normalized()) < -0.05
				previous = p.position
			_release()
			await scene.get_tree().physics_frame
			await scene.get_tree().physics_frame
			var end_clear := not p.test_move(p.global_transform, Vector2.ZERO)
			var idle: bool = String(p.get_node("AnimatedSprite2D").animation).begins_with("idle_")
			var entry := {"chair": str(chair.name), "approach": probe[0], "spawn_clear": start_clear, "sweep_blocked": sweep_ok, "live_contact": contacted, "no_penetration": end_clear, "no_reverse_jitter": not jitter, "idle_after_release": idle, "position": [p.position.x, p.position.y]}
			entry["passed"] = start_clear and sweep_ok and contacted and end_clear and not jitter and idle
			results.append(entry)
			if not entry.passed:
				failures.append(entry)
			if row == 1 and seat == 2 and probe[0] == "rear_seat":
				await capture(scene, mode + "_blocked_backrest.png")
	p.set_physics_process(was_processing)
	var report := {"row": row, "cases": results, "failures": failures, "passed": failures.is_empty()}
	var filename := OUT + mode + "_row%d.json" % row
	var file := FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	return {"row": row, "cases": results.size(), "failures": failures, "passed": failures.is_empty()}


static func navigate(scene: Node2D, mode: String) -> Dictionary:
	var p: CharacterBody2D = scene.get_node("Player")
	var was_processing := p.is_physics_processing()
	p.position = Vector2(754, 628)
	p.velocity = Vector2.ZERO
	p.set_physics_process(true)
	var checks: Array[Dictionary] = []
	await walk(scene, Vector2.RIGHT, 30)
	checks.append({"name": "leave_start", "passed": p.position.x > 815})
	await capture(scene, mode + "_around_chair.png")
	await walk(scene, Vector2.DOWN, 88)
	# Visit each aisle via the south cross-aisle, approach a chair, then back out.
	for target_x: float in [664.0, 500.0, 336.0, 160.0]:
		await move_to_axis(scene, target_x, true)
		await move_to_axis(scene, 700, false)
		checks.append({"name": "aisle_%d" % int(target_x), "passed": absf(p.position.x-target_x) < 4 and absf(p.position.y-700) < 4})
		await move_to_axis(scene, 850, false)
	await move_to_axis(scene, 850, true)
	await move_to_axis(scene, 628, false)
	await walk(scene, Vector2.RIGHT, 70)
	checks.append({"name": "instructor_access", "passed": absf(p.position.x - 976) < 1 and absf(p.position.y-628) < 4})
	checks.append({"name": "fixed_camera", "passed": scene.get_node("FixedCamera").get_screen_center_position().is_equal_approx(Vector2(640,480))})
	await capture(scene, mode + "_instructor.png")
	p.position = Vector2(754,628)
	p.velocity = Vector2.ZERO
	p.get_node("AnimatedSprite2D").facing_sector = 0
	p.get_node("AnimatedSprite2D").show_idle()
	p.set_physics_process(was_processing)
	await capture(scene, mode + "_starting_seat.png")
	var passed := true
	for check: Dictionary in checks:
		passed = passed and check.passed
	var report := {"passed":passed,"checks":checks,"restored_physics":was_processing,"starting_position":[754,628]}
	var file := FileAccess.open(OUT + mode + "_navigation.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	return report


static func move_to_axis(scene: Node2D, target: float, horizontal: bool) -> void:
	var p: CharacterBody2D = scene.get_node("Player")
	for frame: int in range(300):
		var distance := target - (p.position.x if horizontal else p.position.y)
		if absf(distance) < 3:
			break
		_release()
		_press(Vector2(signf(distance),0) if horizontal else Vector2(0,signf(distance)))
		await scene.get_tree().physics_frame
	_release()
	await scene.get_tree().physics_frame
	await scene.get_tree().physics_frame


static func walk(scene: Node2D, direction: Vector2, frames: int) -> void:
	_press(direction)
	for frame: int in range(frames):
		await scene.get_tree().physics_frame
	_release()
	await scene.get_tree().physics_frame
	await scene.get_tree().physics_frame


static func _press(direction: Vector2) -> void:
	if direction.x > 0: Input.action_press("ui_right")
	if direction.x < 0: Input.action_press("ui_left")
	if direction.y > 0: Input.action_press("ui_down")
	if direction.y < 0: Input.action_press("ui_up")


static func _release() -> void:
	for action: String in ["ui_right","ui_left","ui_down","ui_up"]:
		Input.action_release(action)


static func capture(scene: Node2D, filename: String) -> void:
	await RenderingServer.frame_post_draw
	scene.get_viewport().get_texture().get_image().save_png(OUT + filename)
