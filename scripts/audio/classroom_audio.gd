extends Node
## Observe the approved story state without changing screenplay, timers or input.

const GLITCHES = [preload("res://assets/audio/sfx/glitch_01.wav"),preload("res://assets/audio/sfx/glitch_02.wav"),preload("res://assets/audio/sfx/glitch_03.wav")]
const STARTS = [0.015,0.65,0.04]
const GAINS = [-12.0,-14.0,-12.0]
const ADVANCE = preload("res://assets/audio/sfx/dialogue_blip.wav")
@export var selection_seed: int = 1031
var glitch_count: int = 0
var advance_count: int = 0
var selections: Array[int] = []
var _bag: Array[int] = []
var _rng := RandomNumberGenerator.new()
var _last: int = -1
var _slot: int = 0
var _tail_fades: Array[Tween] = [null,null]
@onready var _glitches: Array[AudioStreamPlayer] = [$GlitchA,$GlitchB]

signal manifestation_audio_requested(pair_id: StringName)
@export var populated_gain_db: float = 9.0
## Conservative while the recording's suitability for an empty room awaits listening.
@export var empty_gain_db: float = 1.0
@export var conversation_gain_db: float = -1.0
@onready var opening: Node = get_parent()
@onready var quiz: Node = get_node("../QuizSequence")
@onready var dismissal: Node = get_node("../DismissalSequence")
@onready var conversation: Node = get_node("../ProfessorConversation")

func _ready() -> void:
	_rng.seed = selection_seed
	get_node("../RealityPresentation").transition_started.connect(_on_reality_started)
	get_node("../StoryLayer/DialoguePanel").accepted_line_advanced.connect(_on_accepted_advance)
	AudioDirector.ensure_gameplay_music()
	AudioDirector.start_ambience(self, &"classroom", populated_gain_db, opening.black_hold_seconds + opening.reveal_seconds)

func _process(_delta: float) -> void:
	var intrusive: bool = quiz.phase == quiz.Phase.INTERRUPTION or dismissal.phase == dismissal.Phase.INTERRUPTION or conversation.phase == conversation.Phase.INTERRUPTION
	AudioDirector.set_whisper_duck(intrusive)

func _on_dismissal_cue(id: StringName, _direction: String) -> void:
	if id == &"room_empties":
		AudioDirector.fade_ambience(empty_gain_db, dismissal.fade_seconds)

func _on_conversation_started() -> void:
	AudioDirector.fade_ambience(conversation_gain_db, 1.0)

func _on_manifestation_requested(pair_id: StringName) -> void:
	# Explicit future integration hook. No substitute manifestation audio is triggered.
	manifestation_audio_requested.emit(pair_id)

func _exit_tree() -> void:
	AudioDirector.release(self)
func _on_reality_started(_from: int, _toward: int, _cue: StringName) -> void:
	if _bag.is_empty():
		_bag.assign([0,1,2])
		for i in range(2,0,-1):
			var j: int = _rng.randi_range(0,i)
			var previous: int = _bag[i]; _bag[i] = _bag[j]; _bag[j] = previous
		if _bag.back() == _last:
			var previous: int = _bag[0]; _bag[0] = _bag[2]; _bag[2] = previous
	var choice: int = _bag.pop_back()
	_last = choice
	selections.append(choice)
	glitch_count += 1
	var old: int = _slot
	_slot = 1-_slot
	for i in 2:
		if is_instance_valid(_tail_fades[i]): _tail_fades[i].kill()
	if _glitches[old].playing:
		_tail_fades[old] = create_tween()
		_tail_fades[old].tween_property(_glitches[old],"volume_db",-80.0,0.04)
		_tail_fades[old].tween_callback(_glitches[old].stop)
	_glitches[_slot].stop()
	_glitches[_slot].stream = GLITCHES[choice]
	_glitches[_slot].volume_db = GAINS[choice]
	_glitches[_slot].play(STARTS[choice])

func _on_accepted_advance() -> void:
	advance_count += 1
	$Advance.stream = ADVANCE
	# One short impact, not the recording's quiet lead-in; no per-character hookup.
	$Advance.play(0.12)
