extends Node
## Scene adapter: one cast, exclusive environment art, one profiled lighting pass.
const MANIFESTED_PROFESSOR = preload("res://assets/characters/classroom/manifested/professor_manifested_frames.tres")
const MANIFESTED_CAST: Dictionary = {
	&"Jules": preload("res://assets/characters/classroom/manifested/jules_manifested_frames.tres"),
	&"Liezel": preload("res://assets/characters/classroom/manifested/liezel_manifested_frames.tres"),
	&"ClassmateMale01": preload("res://assets/characters/classroom/manifested/classmate_male_01_manifested_frames.tres"),
	&"ClassmateMale02": preload("res://assets/characters/classroom/manifested/classmate_male_02_manifested_frames.tres"),
	&"ClassmateFemale01": preload("res://assets/characters/classroom/manifested/classmate_female_01_manifested_frames.tres"),
	&"ClassmateFemale02": preload("res://assets/characters/classroom/manifested/classmate_female_02_manifested_frames.tres"),
	&"ClassmateFemale03": preload("res://assets/characters/classroom/manifested/classmate_female_03_manifested_frames.tres"),
	&"Professor": MANIFESTED_PROFESSOR,
}
@onready var normal: Node2D = get_node("../Foundation/Classroom/Presentation/Normal")
@onready var manifested: Node2D = get_node("../Foundation/Classroom/Presentation/Manifested")
@onready var lighting: CanvasLayer = get_node("../Foundation/ClassroomLighting")
@onready var sunlight: Node = get_node("../Foundation/ClassroomShadows")
@onready var ceiling: Node = get_node("../Foundation/CeilingShadowCache")
@onready var player: CharacterBody2D = get_node("../Foundation/Player")
@onready var professor: AnimatedSprite2D = get_node("../Foundation/NormalNPCs/Professor/AnimatedSprite2D")
@onready var dismissal: Node = get_node("../DismissalSequence")
@onready var cast: Node2D = get_node("../Foundation/NormalNPCs")
var _saved: Dictionary = {}

func can_present_manifested() -> bool:
	# Quiz/dismissal intrusions are also authorized locked story segments. Never
	# admit free exploration or interrupt the opening/dismissal blackout itself.
	if player.is_physics_processing() or get_node("../RevealLayer/Blackout").visible:
		return false
	var quiz: Node = get_node("../QuizSequence")
	var quiz_active: bool = quiz.phase not in [quiz.Phase.WAITING, quiz.Phase.COMPLETE]
	var dismissal_active: bool = not dismissal.exploration_active and dismissal.phase not in [dismissal.Phase.WAITING, dismissal.Phase.COMPLETE]
	return quiz_active or dismissal_active or (dismissal.exploration_active and dismissal.interaction_suspended)

func present_manifested() -> void:
	_saved = {"normal_visible":normal.visible,"lighting_visible":lighting.visible,
		"movement":player.is_physics_processing(),"suspended":dismissal.interaction_suspended,
		"process":[],"collisions":[],"actors":[]}
	dismissal.interaction_suspended = true
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	var geometry = get_node("../Foundation/Classroom/Geometry")
	var shapes = geometry.find_children("*","CollisionShape2D",true,false)
	shapes.append_array(geometry.find_children("*","CollisionPolygon2D",true,false))
	shapes.append(get_node("../ProfessorFootprint/Feet"))
	for shape in shapes:
		_saved.collisions.append([shape,shape.disabled])
		shape.set_deferred("disabled",true)
	var processors: Array = [ceiling]
	for node in processors:
		_saved.process.append([node,node.is_processing()])
		node.set_process(false)
	for viewport in ceiling.masks + [ceiling.surface]:
		viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	# Invisible/dismissed actors are not swapped, enabled or respawned.
	for actor: Node2D in cast.get_children():
		if not actor.is_visible_in_tree() or not MANIFESTED_CAST.has(actor.name): continue
		var visual: AnimatedSprite2D = actor.get_node("AnimatedSprite2D")
		_saved.actors.append({"visual":visual,"frames":visual.sprite_frames})
		_swap_frames(visual, MANIFESTED_CAST[actor.name])
	normal.hide()
	manifested.show()
	sunlight.set_presentation_map(manifested.get_node("Artwork"), true)
	lighting.set_manifested_profile(true)
	lighting.show()

func present_normal() -> void:
	manifested.hide()
	for entry in _saved.actors: _swap_frames(entry.visual, entry.frames)
	for entry in _saved.collisions:entry[0].set_deferred("disabled",entry[1])
	# Refresh from current global time; never restore an old illumination snapshot.
	lighting.set_manifested_profile(false)
	lighting._update(0.0)
	sunlight.set_presentation_map(normal.get_node("Artwork"), false)
	for entry in ceiling._actors:entry.last = []
	for entry in _saved.process:entry[0].set_process(entry[1])
	for viewport in ceiling.masks + [ceiling.surface,sunlight.mask]:
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	normal.visible = _saved.normal_visible
	lighting.visible = _saved.lighting_visible
	dismissal.interaction_suspended = _saved.suspended
	player.set_physics_process(_saved.movement)
	_saved.clear()

func _swap_frames(visual: AnimatedSprite2D, frames: SpriteFrames) -> void:
	# Carry the CURRENT breathing/step phase both ways, never rewind to entry time.
	var animation: StringName = visual.animation
	var frame: int = visual.frame
	var progress: float = visual.frame_progress
	var playing: bool = visual.is_playing()
	var mirrored: bool = visual.flip_h
	visual.sprite_frames = frames
	visual.animation = animation
	visual.set_frame_and_progress(frame, progress)
	visual.flip_h = mirrored
	if playing: visual.play()
	else: visual.pause()
