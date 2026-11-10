extends "res://scripts/audio/school_exterior_audio.gd"
## Missing recordings remain silent hooks. The original music stream is never replaced.
signal production_cue_requested(cue: StringName)
@export var clarity_filter: AudioEffectLowPassFilter
var missing_cues: Array[StringName]=[]
var road_active: bool=false
var advance_count: int=0
var _distance: float=0.0
var _previous:=Vector2.ZERO
var _last_gain: float=INF
var _filter_on: bool=false
var _music_bus: int=-1
var _walkway_mix: Tween
var _walkway_music_db: float
@onready var player: Node2D=get_node("../Player")

func _ready() -> void:
	super._ready()
	_music_bus=AudioServer.get_bus_index("Music")
	_walkway_music_db=AudioServer.get_bus_volume_db(_music_bus)
	AudioServer.add_bus_effect(_music_bus,clarity_filter)
	AudioServer.set_bus_effect_enabled(_music_bus,AudioServer.get_bus_effect_count(_music_bus)-1,false)

func _on_accepted_advance() -> void:
	advance_count+=1
	$Advance.play(.12)

func on_cue(id: StringName) -> void:
	if id in [&"gate_atmosphere",&"passing_traffic",&"faint_wind",&"phone_message"]:
		missing_cues.append(id)
		production_cue_requested.emit(id)
	if id==&"road_atmosphere":
		road_active=true
		_previous=player.position
		AudioDirector.fade_ambience(6.0,1.8)
	elif id==&"music_clarity":
		_filter_on=true
		for i in AudioServer.get_bus_effect_count(_music_bus):
			if AudioServer.get_bus_effect(_music_bus,i)==clarity_filter: AudioServer.set_bus_effect_enabled(_music_bus,i,true)

func _process(delta: float) -> void:
	if road_active:
		_distance+=player.position.distance_to(_previous)
		_previous=player.position
		var gain: float=6.0-9.0*clampf(_distance/650.0,0.0,1.0)
		if absf(gain-_last_gain)>=1.0:
			_last_gain=gain
			AudioDirector.fade_ambience(gain,.8)
	if _filter_on: clarity_filter.cutoff_hz=move_toward(clarity_filter.cutoff_hz,6500.0,delta*4500.0)

func cancel_presentation() -> void:
	_filter_on=false
	road_active=false
	if _music_bus<0: return
	finish_walkway_mix(false)
	for i in range(AudioServer.get_bus_effect_count(_music_bus)-1,-1,-1):
		if AudioServer.get_bus_effect(_music_bus,i)==clarity_filter: AudioServer.remove_bus_effect(_music_bus,i)

func _exit_tree() -> void:
	cancel_presentation()
	super._exit_tree()

func _on_walkway_cue(id: StringName,_direction: String) -> void:
	if id==&"walkway_sound": AudioDirector.fade_ambience(-3.0,1.8)
	elif id in [&"phone_in_pocket",&"final_music_hold"]:
		missing_cues.append(id)
		if id==&"final_music_hold":
			_walkway_mix=create_tween()
			_walkway_mix.tween_method(func(db):AudioDirector.set_bus_level(&"Music",db),_walkway_music_db,_walkway_music_db-3.0,1.8)

func finish_walkway_mix(restore_ambience: bool=true) -> void:
	if is_instance_valid(_walkway_mix):_walkway_mix.kill()
	AudioDirector.set_bus_level(&"Music",_walkway_music_db)
	if restore_ambience:AudioDirector.fade_ambience(12.0 if _group==&"school_morning" else 9.0,1.8)
