extends RefCounted
## Test fixtures only; no instructor NPC or interaction behavior.

const MOVE = preload("res://scenes/tests/classroom_collision_refinement_tests.gd")
const OUT := "res://docs/classroom/instructor_access/"


static func north(scene: Node2D) -> Dictionary:
	var p: CharacterBody2D = scene.get_node("Player")
	p.position = Vector2(754,628)
	p.velocity = Vector2.ZERO
	var checks: Array[Dictionary] = []
	await MOVE.move_to_axis(scene,850,true)
	await MOVE.move_to_axis(scene,450,false)
	await MOVE.move_to_axis(scene,1122,true)
	await MOVE.move_to_axis(scene,572,false)
	checks.append(at(p,Vector2(1122,572),"standing_interaction_approach"))
	await capture(scene,"live_standing_approach.png")
	await MOVE.move_to_axis(scene,1154,true)
	await MOVE.move_to_axis(scene,620,false)
	checks.append(at(p,Vector2(1154,620),"future_seating_anchor"))
	await capture(scene,"live_seating_anchor.png")
	await MOVE.move_to_axis(scene,450,false)
	checks.append(at(p,Vector2(1154,450),"leave_chair_to_north"))
	return save("north",checks)


static func east(scene: Node2D) -> Dictionary:
	var p: CharacterBody2D = scene.get_node("Player")
	var checks: Array[Dictionary] = []
	await MOVE.move_to_axis(scene,1210,true)
	await MOVE.move_to_axis(scene,620,false)
	checks.append(at(p,Vector2(1210,620),"east_floor_beside_chair"))
	await capture(scene,"live_east_approach.png")
	await MOVE.walk(scene,Vector2.LEFT,24)
	checks.append(at(p,Vector2(1200,620),"chair_back_post_blocks_crossing"))
	await MOVE.move_to_axis(scene,1210,true)
	await MOVE.move_to_axis(scene,450,false)
	await MOVE.move_to_axis(scene,1154,true)
	checks.append(at(p,Vector2(1154,450),"east_retreat_to_north"))
	return save("east",checks)


static func south(scene: Node2D) -> Dictionary:
	var p: CharacterBody2D = scene.get_node("Player")
	var checks: Array[Dictionary] = []
	await MOVE.move_to_axis(scene,850,true)
	await MOVE.move_to_axis(scene,850,false)
	await MOVE.move_to_axis(scene,1154,true)
	await MOVE.move_to_axis(scene,720,false)
	checks.append(at(p,Vector2(1154,720),"south_floor_in_front_of_chair"))
	await MOVE.walk(scene,Vector2.UP,24)
	checks.append(at(p,Vector2(1154,692),"chair_support_blocks_crossing"))
	await capture(scene,"live_south_chair.png")
	await MOVE.move_to_axis(scene,850,false)
	await MOVE.move_to_axis(scene,1045,true)
	await MOVE.walk(scene,Vector2.UP,30)
	checks.append(at(p,Vector2(1045,804),"desk_south_footprint"))
	await MOVE.move_to_axis(scene,850,false)
	checks.append(at(p,Vector2(1045,850),"south_retreat"))
	return save("south",checks)


static func west(scene: Node2D) -> Dictionary:
	var p: CharacterBody2D = scene.get_node("Player")
	var checks: Array[Dictionary] = []
	await MOVE.move_to_axis(scene,850,true)
	await MOVE.move_to_axis(scene,628,false)
	await MOVE.walk(scene,Vector2.RIGHT,60)
	checks.append(at(p,Vector2(976,628),"west_desk_approach"))
	await capture(scene,"live_west_desk.png")
	await MOVE.move_to_axis(scene,850,true)
	checks.append(at(p,Vector2(850,628),"west_retreat"))
	return save("west",checks)


static func at(p: CharacterBody2D, target: Vector2, label: String) -> Dictionary:
	return {"name":label,"passed":p.position.distance_to(target)<4 and not p.test_move(p.global_transform,Vector2.ZERO),"position":[p.position.x,p.position.y]}


static func save(label: String, checks: Array[Dictionary]) -> Dictionary:
	var passed := true
	for check: Dictionary in checks:
		passed = passed and check.passed
	var report := {"passed":passed,"checks":checks}
	var file := FileAccess.open(OUT+label+"_navigation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	return report


static func capture(scene: Node2D, filename: String) -> void:
	await RenderingServer.frame_post_draw
	scene.get_viewport().get_texture().get_image().save_png(OUT+filename)
