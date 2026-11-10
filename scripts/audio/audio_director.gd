extends Node
## Persistent gameplay music; scene-owned ambience remains independently releasable.
## Two fixed ambience voices serve both loop overlaps and group transitions.

const AMBIENCE = {
	&"classroom": preload("res://assets/audio/ambience/classroom.ogg"),
	&"school_morning": preload("res://assets/audio/ambience/school_morning.ogg"),
	&"school_night": preload("res://assets/audio/ambience/school_night.ogg"),
}
const SOUNDTRACK = preload("res://assets/audio/music/soundtrack.ogg")

@export var loop_overlap_seconds: float = 1.5
@export var group_crossfade_seconds: float = 2.0
@export var music_gain_db: float = -10.0
@export var whisper_duck_db: float = -3.0
@onready var voices: Array[AudioStreamPlayer] = [$AmbienceA, $AmbienceB]
@export var music_overlap_seconds: float = 2.0
@onready var music: AudioStreamPlayer = $Music
@onready var music_voices: Array[AudioStreamPlayer] = [$Music, $MusicB]

var ambience_id: StringName = &""
var ambience_starts: int = 0
var loop_transitions: int = 0
var _owner: Node
var music_starts: int = 0
var music_loops: int = 0
var _music_enabled: bool = false
var _music_looping: bool = false
var _music_blending: bool = false
var _music_elapsed: float = 0.0
var _music_duration: float = 2.0
var _music_level_db: float = -80.0
var _music_target_gain_db: float = -10.0
var _music_stream: AudioStream
var _music_next_stream: AudioStream
var _music_next_looping: bool = false
var _current: int = 0
var _incoming: int = 1
var _blending: bool = false
var _blend_elapsed: float = 0.0
var _blend_duration: float = 1.5
var _pending: StringName = &""
var _level_db: float = -80.0
var _duck_db: float = 0.0
var _duck_wanted: bool = false
var _duck_release_delay: float = 0.0
var _level_tween: Tween
var _music_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_ambience(owner_node: Node, id: StringName, gain_db: float, fade_seconds: float = 1.5) -> void:
	if not AMBIENCE.has(id):
		push_error("Unknown ambience cue: " + String(id))
		return
	var same_owner: bool = _owner == owner_node
	_owner = owner_node
	if not same_owner:
		_duck_wanted = false
		_duck_db = 0.0
		_duck_release_delay = 0.0
	if ambience_id == id:
		_pending = &""
		if not same_owner:
			fade_ambience(gain_db, fade_seconds)
		return
	_pending = id
	if not voices[_current].playing and not _blending:
		ambience_id = id
		_pending = &""
		_start_voice(_current, id)
		_level_db = gain_db - 12.0
		fade_ambience(gain_db, fade_seconds)
	elif not _blending:
		_begin_blend(id, group_crossfade_seconds)
		fade_ambience(gain_db, fade_seconds)
	else:
		# Finish the bounded two-voice overlap before switching to the latest request.
		fade_ambience(gain_db, fade_seconds)

func fade_ambience(gain_db: float, seconds: float = 1.0) -> void:
	if is_instance_valid(_level_tween):
		_level_tween.kill()
	_level_tween = create_tween()
	_level_tween.tween_property(self, "_level_db", gain_db, maxf(seconds, 0.01))

func set_whisper_duck(active: bool) -> void:
	if active == _duck_wanted:
		return
	_duck_wanted = active
	if not active:
		_duck_release_delay = 0.3

func stop_ambience(seconds: float = 0.8) -> void:
	_owner = null
	_pending = &""
	fade_ambience(-80.0, seconds)
	_level_tween.tween_callback(_stop_voices)

func release(owner_node: Node) -> void:
	if _owner == owner_node:
		_owner = null
		stop_ambience()

## Idempotent gameplay entry; releasing a scene never releases persistent music.
func ensure_gameplay_music() -> void:
	if _music_enabled: return
	play_music(self, 1.5, SOUNDTRACK, true)

## Explicit future cue changes crossfade; no automatic story cue changes.
## Default preserves the old one-shot API for callers requesting a cue deliberately.
func play_music(_owner_node: Node, fade_seconds: float = 1.5, stream: AudioStream = SOUNDTRACK, looping: bool = false, gain_override_db: Variant = null) -> void:
	if stream == null: return
	var target_gain_db: float = music_gain_db if gain_override_db == null else clampf(float(gain_override_db), -60.0, 0.0)
	if _music_enabled and _music_stream == stream and (music.playing or _music_blending):
		_music_looping = looping
		if not is_equal_approx(_music_target_gain_db, target_gain_db):
			_music_target_gain_db = target_gain_db
			if is_instance_valid(_music_tween): _music_tween.kill()
			_music_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
			_music_tween.tween_property(self, "_music_level_db", target_gain_db, maxf(fade_seconds, 0.01))
		return
	_music_enabled = true
	_music_target_gain_db = target_gain_db
	if music.playing:
		if _music_blending:
			_music_next_stream = stream
			_music_next_looping = looping
			return
		if is_instance_valid(_music_tween): _music_tween.kill()
		_music_looping = looping
		_begin_music_blend(stream, fade_seconds)
	else:
		if is_instance_valid(_music_tween): _music_tween.kill()
		_music_stream = stream
		_music_looping = looping
		music.stream = stream
		music.play()
		music_starts += 1
		_music_level_db = -80.0
	_music_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	_music_tween.tween_property(self, "_music_level_db", target_gain_db, maxf(fade_seconds,0.01))

func stop_music(seconds: float = 1.0) -> void:
	_music_enabled = false
	_music_next_stream = null
	if is_instance_valid(_music_tween): _music_tween.kill()
	_music_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	_music_tween.tween_property(self,"_music_level_db",-80.0,maxf(seconds,0.01))
	_music_tween.tween_callback(_stop_music_voices)

func _stop_music_voices() -> void:
	for voice in music_voices: voice.stop()
	_music_blending = false
	_music_stream = null

func _begin_music_blend(stream: AudioStream, seconds: float) -> void:
	var incoming: AudioStreamPlayer = music_voices[1] if music == music_voices[0] else music_voices[0]
	incoming.stream = stream
	incoming.volume_linear = 0.0
	incoming.play()
	music_starts += 1
	_music_stream = stream
	_music_elapsed = 0.0
	_music_duration = clampf(seconds,0.05,stream.get_length()*0.25)
	_music_blending = true

func _update_music(delta: float) -> void:
	var incoming: AudioStreamPlayer = music_voices[1] if music == music_voices[0] else music_voices[0]
	var gain: float = db_to_linear(_music_level_db)
	if _music_blending:
		_music_elapsed += delta
		var t: float = clampf(_music_elapsed/_music_duration,0.0,1.0)
		music.volume_linear = gain*(1.0-t)
		incoming.volume_linear = gain*t
		if t>=1.0:
			music.stop()
			music = incoming
			_music_blending = false
	else:
		music.volume_linear = gain
	if _music_enabled and not _music_blending:
		if _music_next_stream != null:
			var next: AudioStream = _music_next_stream
			_music_next_stream = null
			_music_looping = _music_next_looping
			_begin_music_blend(next,music_overlap_seconds)
		elif _music_looping and music.playing and music.get_playback_position() >= music.stream.get_length()-minf(music_overlap_seconds,music.stream.get_length()*0.25):
			music_loops += 1
			_begin_music_blend(_music_stream,music_overlap_seconds)

func set_bus_level(bus: StringName, gain_db: float) -> void:
	# User-facing mix attenuation preserves the calibrated playback headroom.
	if bus not in [&"Music", &"Ambience", &"Footsteps"]:
		return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), clampf(gain_db, -60.0, 0.0))

func _start_voice(index: int, id: StringName) -> void:
	voices[index].stream = AMBIENCE[id]
	voices[index].volume_db = -80.0
	voices[index].play()
	ambience_starts += 1

func _begin_blend(id: StringName, seconds: float) -> void:
	_incoming = 1 - _current
	_start_voice(_incoming, id)
	_blend_duration = maxf(0.1, seconds)
	_blend_elapsed = 0.0
	_blending = true
	if _pending == id:
		_pending = &""
	ambience_id = id

func _stop_voices() -> void:
	for voice in voices:
		voice.stop()
	_blending = false
	ambience_id = &""
	_pending = &""

func _process(delta: float) -> void:
	# Director stays ALWAYS for existing ambience fades, but music is pausable.
	for voice in music_voices: voice.stream_paused = get_tree().paused
	if not get_tree().paused: _update_music(delta)
	if _owner != null and not is_instance_valid(_owner):
		_owner = null
		stop_ambience()
	# Slow release and a short latch prevent pumping between neighboring intrusions.
	_duck_release_delay = maxf(0.0, _duck_release_delay - delta)
	var target: float = whisper_duck_db if _duck_wanted or _duck_release_delay > 0.0 else 0.0
	_duck_db = lerpf(_duck_db, target, 1.0 - exp(-delta / (0.15 if _duck_wanted else 0.8)))
	var gain: float = db_to_linear(_level_db + _duck_db)
	if _blending:
		_blend_elapsed += delta
		var t: float = clampf(_blend_elapsed / _blend_duration, 0.0, 1.0)
		# Complementary linear gains sum to one, including correlated loop overlaps.
		voices[_current].volume_linear = gain * (1.0 - t)
		voices[_incoming].volume_linear = gain * t
		if t >= 1.0:
			voices[_current].stop()
			_current = _incoming
			_blending = false
	else:
		voices[_current].volume_linear = gain
	if not _blending and _owner != null:
		if not _pending.is_empty():
			_begin_blend(_pending, group_crossfade_seconds)
		elif voices[_current].playing and voices[_current].get_playback_position() >= voices[_current].stream.get_length() - loop_overlap_seconds:
			loop_transitions += 1
			_begin_blend(ambience_id, loop_overlap_seconds)
