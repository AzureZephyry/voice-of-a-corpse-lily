extends Node
## Surface evidence: the authored ground layer, registered through Map's transform.
## Green lawn = grass; pale neutral paving = concrete; asphalt/unknown stays silent.

const GROUND = preload("res://assets/environments/school_exterior/ground/school_ground_paths_base.png")
@onready var lighting: Node2D = get_node("../SchoolExterior")
@onready var map: Sprite2D = get_node("../SchoolExterior/Map")
var _ground: Image
var _group: StringName = &""

func _ready() -> void:
	AudioDirector.ensure_gameplay_music()
	_ground = GROUND.get_image()
	GameClock.minute_changed.connect(_on_minute_changed)
	GameClock.time_overridden.connect(_on_time_overridden)
	_refresh()

func _refresh() -> void:
	var phase: Dictionary = lighting.sample_at(GameClock.get_minutes())
	var desired: StringName = &"school_morning" if phase.name in ["Morning", "Noon", "Afternoon", "Sunset"] else &"school_night"
	if desired == _group:
		return
	_group = desired
	AudioDirector.start_ambience(self, desired, 12.0 if desired == &"school_morning" else 9.0)

func _on_minute_changed(_hour: int, _minute: int) -> void:
	_refresh()

func _on_time_overridden(_previous: float, _current: float) -> void:
	_refresh()

func surface_at(world_position: Vector2) -> StringName:
	var pixel := Vector2i(map.to_local(world_position).floor())
	var grass: int = 0
	var paving: int = 0
	for x in [-2, 0, 2]:
		for y in [-2, 0, 2]:
			var p := pixel + Vector2i(x, y)
			if p.x < 0 or p.y < 0 or p.x >= _ground.get_width() or p.y >= _ground.get_height():
				continue
			var color: Color = _ground.get_pixelv(p)
			if color.g > color.r * 1.25 and color.g > color.b * 1.1:
				grass += 1
			elif minf(color.r, minf(color.g, color.b)) > 0.55 and maxf(color.r, maxf(color.g, color.b)) - minf(color.r, minf(color.g, color.b)) < 0.18:
				paving += 1
	return &"grass" if grass >= 5 else (&"concrete" if paving >= 5 else &"")

func _exit_tree() -> void:
	if GameClock.minute_changed.is_connected(_on_minute_changed):
		GameClock.minute_changed.disconnect(_on_minute_changed)
	if GameClock.time_overridden.is_connected(_on_time_overridden):
		GameClock.time_overridden.disconnect(_on_time_overridden)
	AudioDirector.release(self)