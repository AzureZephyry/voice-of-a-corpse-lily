extends Node
## Shared fractional simulation time: one active real second per in-game minute.

signal minute_changed(hour: int, minute: int)
signal time_overridden(previous_minutes: float, current_minutes: float)

const MINUTES_PER_DAY: float = 1440.0
const REAL_SECONDS_PER_MINUTE: float = 1.0
const INITIAL_MINUTES: float = 390.0

var _minutes: float = INITIAL_MINUTES
var _holds: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta: float) -> void:
	_advance_elapsed(delta)

func _advance_elapsed(real_seconds: float) -> void:
	if real_seconds <= 0.0 or get_tree().paused or is_held():
		return
	var previous: int = floori(_minutes)
	_minutes = fposmod(_minutes + real_seconds / REAL_SECONDS_PER_MINUTE, MINUTES_PER_DAY)
	if floori(_minutes) != previous:
		minute_changed.emit(get_hour(), get_minute())

func set_time(hour: int, minute: int = 0) -> bool:
	if hour < 0 or hour > 23 or minute < 0 or minute > 59:
		return false
	var previous_time: float = _minutes
	var previous: int = floori(previous_time)
	_minutes = float(hour * 60 + minute)
	time_overridden.emit(previous_time, _minutes)
	if floori(_minutes) != previous:
		minute_changed.emit(get_hour(), get_minute())
	return true

func get_minutes() -> float:
	return _minutes

func get_hour() -> int:
	return floori(_minutes / 60.0)

func get_minute() -> int:
	return floori(_minutes) % 60

func get_day_fraction() -> float:
	return _minutes / MINUTES_PER_DAY

## Holds are opt-in and owner-scoped; explicit story time overrides still work.
func hold(owner_node: Node) -> void:
	_holds[owner_node.get_instance_id()] = weakref(owner_node)

func release(owner_node: Node) -> void:
	_holds.erase(owner_node.get_instance_id())

func is_held() -> bool:
	for id in _holds.keys():
		if _holds[id].get_ref() == null:
			_holds.erase(id)
	return not _holds.is_empty()
