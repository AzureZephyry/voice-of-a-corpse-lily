extends RefCounted
## Isolated runtime probes for the instructor-side exclusion and access routes.

const OUT := "res://docs/classroom/instructor_boundary/"
const MOVEMENT = preload("res://scenes/tests/classroom_collision_refinement_tests.gd")


static func probe(scene: Node2D, label: String, start: Vector2, direction: Vector2, frames: int, expected: Vector2) -> Dictionary:
	var p: CharacterBody2D = scene.get_node("Player")
	var was_enabled := p.is_physics_processing()
	p.set_physics_process(true)
	p.position = start
	p.velocity = Vector2.ZERO
	await scene.get_tree().physics_frame
	await scene.get_tree().physics_frame
	var start_clear := not p.test_move(p.global_transform,Vector2.ZERO)
	var jitter := false
	var previous := p.position
	var contacted := false
	MOVEMENT._press(direction)
	for frame: int in range(frames):
		await scene.get_tree().physics_frame
		jitter = jitter or (p.position-previous).dot(direction.normalized()) < -0.05
		contacted = contacted or p.get_slide_collision_count() > 0
		previous = p.position
	MOVEMENT._release()
	await scene.get_tree().physics_frame
	await scene.get_tree().physics_frame
	var clear := not p.test_move(p.global_transform,Vector2.ZERO)
	var passed := start_clear and clear and not jitter and contacted and p.position.distance_to(expected) < 4
	var report := {"passed":passed,"label":label,"start_clear":start_clear,"end_clear":clear,"no_reverse_jitter":not jitter,"contacted":contacted,"position":[p.position.x,p.position.y],"expected":[expected.x,expected.y]}
	p.set_physics_process(was_enabled)
	await capture(scene,label+".png")
	var file := FileAccess.open(OUT+label+".json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	return report


static func capture(scene: Node2D, filename: String) -> void:
	await RenderingServer.frame_post_draw
	scene.get_viewport().get_texture().get_image().save_png(OUT+filename)
