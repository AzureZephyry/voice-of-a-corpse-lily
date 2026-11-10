extends Node
## Passive accepted-transition audio; uses the established Lawrence cue mix.
const GLITCHES = [preload("res://assets/audio/sfx/glitch_01.wav"), preload("res://assets/audio/sfx/glitch_02.wav"), preload("res://assets/audio/sfx/glitch_03.wav")]
const STARTS = [0.015, 0.65, 0.04]
const GAINS = [-12.0, -14.0, -12.0]
@export var selection_seed: int = 1031
var glitch_count: int = 0
var selections: Array[int] = []
var _bag: Array[int] = []
var _rng := RandomNumberGenerator.new()
var _last: int = -1
var _slot: int = 0
var _tail_fades: Array[Tween] = [null, null]
@onready var _players: Array[AudioStreamPlayer] = [$GlitchA, $GlitchB]


func _ready() -> void:
	_rng.seed = selection_seed


func _on_transition_started(_from: int, _toward: int, _cue: StringName) -> void:
	if _bag.is_empty():
		_bag.assign([0, 1, 2])
		for i in range(2, 0, -1):
			var j: int = _rng.randi_range(0, i)
			var previous: int = _bag[i]
			_bag[i] = _bag[j]
			_bag[j] = previous
		if _bag.back() == _last:
			var previous: int = _bag[0]
			_bag[0] = _bag[2]
			_bag[2] = previous
	var choice: int = _bag.pop_back()
	_last = choice
	selections.append(choice)
	if selections.size() > 64:
		selections.pop_front()
	glitch_count += 1
	var old: int = _slot
	_slot = 1 - _slot
	for i in 2:
		if is_instance_valid(_tail_fades[i]):
			_tail_fades[i].kill()
	if _players[old].playing:
		_tail_fades[old] = create_tween()
		_tail_fades[old].tween_property(_players[old], "volume_db", -80.0, 0.04)
		_tail_fades[old].tween_callback(_players[old].stop)
	_players[_slot].stop()
	_players[_slot].stream = GLITCHES[choice]
	_players[_slot].volume_db = GAINS[choice]
	_players[_slot].play(STARTS[choice])


func _exit_tree() -> void:
	for fade in _tail_fades:
		if is_instance_valid(fade):
			fade.kill()
