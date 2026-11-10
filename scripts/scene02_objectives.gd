extends CanvasLayer
## Scene-local progression, rendered by the existing shared objective checklist.
@export_enum("Hallway", "Exterior") var location_kind: int = 0
@export var completed_ids: Array[StringName] = []
@export_node_path("Node") var narrative_path: NodePath=^"../Narrative"
@onready var narrative: Node = get_node(narrative_path)
@onready var objective: Label = $Objective
var active_id: StringName
var history: Array[Dictionary] = []
const TITLES = {&"talk":"Talk to Jules and Liezel", &"depart":"Walk left past your friends", &"gate":"Go to the main gate", &"air":"Get some air", &"outside":"Head outside", &"quiet":"Find somewhere quiet", &"moment":"Take a moment"}

func _ready() -> void:
	if location_kind == 0:
		narrative.stage_changed.connect(_on_hallway_stage)
		_activate(&"talk")
	else:
		narrative.stage_direction.connect(_on_exterior_cue)
		narrative.exterior_segment_completed.connect(finish_objectives)
		_activate(&"quiet")
		set_physics_process(false)

func _activate(id: StringName) -> void:
	if id == active_id: return
	active_id = id
	history.append({"id":id,"clock":GameClock.get_minutes(),"completed":completed_ids.duplicate()})
	var flags: Array[bool] = [false]
	objective.present("Objective", PackedStringArray([TITLES[id]]), flags)
	objective.show()

func _complete(id: StringName) -> void:
	if not completed_ids.has(id): completed_ids.append(id)

func _on_hallway_stage(stage: int) -> void:
	if stage == narrative.Stage.DEPARTURE:
		_complete(&"talk")
		_activate(&"depart")
	elif stage == narrative.Stage.FREE:
		_complete(&"talk")
		_complete(&"depart")
		_activate(&"air")
	elif stage == narrative.Stage.DONE:
		var marker=get_node_or_null("../StairExitMarker")
		if marker!=null:marker.hide()
		_complete(&"air")
		_complete(&"outside")
		objective.finish_and_hide()
	elif stage == narrative.Stage.CANCELLED:
		objective.hide()

func _physics_process(_delta: float) -> void:
	var marker=get_node_or_null("../StairExitMarker")
	if marker!=null:marker.visible=location_kind==0 and active_id==&"outside" and narrative.stage==narrative.Stage.FREE
	if location_kind == 0 and narrative.stage == narrative.Stage.FREE and active_id == &"air" and narrative.player.position.x <= 1900.0:
		_complete(&"air")
		_activate(&"outside")

func _on_exterior_cue(id: StringName, _direction: String) -> void:
	if id == &"bench_composition":
		_complete(&"quiet")
		_activate(&"moment")

func finish_objectives() -> void:
	_complete(&"moment")
	_activate(&"gate")
