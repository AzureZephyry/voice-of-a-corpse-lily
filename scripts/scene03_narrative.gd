extends "res://scripts/classroom_quiz.gd"
## Uses the proven reveal/advance runner. Explicit reality metadata gates each line on the existing transition-completion contract.
const Screenplay=preload("res://scripts/scene03_screenplay.gd")
var road: bool=false
var gate_finished: bool=false
var road_started: bool=false
var cancelled: bool=false
var event_trace: Array[Dictionary]=[]
var _last_walk:=Vector2.RIGHT
const ROAD_BEATS={0:620.0,6:800.0,8:980.0,9:1100.0,13:1280.0}
var road_origin_x: float=568.0
var road_direction: float=0.0
var waiting_beat: int=-1
var released_beats: Dictionary={}
var beat_trace: Array[Dictionary]=[]
@onready var host: Node=get_parent()

func _ready() -> void:
	super._ready()
	body.preserve_source_punctuation=true
	var font: Font=body.get_theme_font("font").duplicate()
	var punctuation:=FontVariation.new()
	punctuation.base_font=ThemeDB.fallback_font
	punctuation.variation_transform=Transform2D(Vector2(.55,0),Vector2(0,.55),Vector2.ZERO)
	font.fallbacks=[punctuation]
	body.add_theme_font_override("font",font)
	body.set_process_unhandled_key_input(false)
	host.encounter_requested.connect(begin_gate)
	host.pedestrian_exit_crossed.connect(_on_gate_exit)
	quiz_finished.connect(_on_finished)
	stage_direction.connect(_on_stage)

func begin_gate() -> void:
	if gate_finished or phase!=Phase.WAITING or cancelled: return
	host.get_node("BoardInteraction").suspended=true
	host.guard.face_direction(player.position-host.guard.position)
	_on_opening_finished()

func _on_gate_exit() -> void:
	if host.gate_exited and gate_finished and not road_started and not cancelled:
		_begin_road.call_deferred()

func _begin_road() -> void:
	if road_started or cancelled or not host.gate_exited: return
	road=true
	road_origin_x=player.global_position.x
	road_started=true
	player.road_active=true
	phase=Phase.WAITING
	step_index=-1
	_on_opening_finished()

func sequence_steps() -> Array[Dictionary]:
	return Screenplay.ROAD if road else Screenplay.GATE

func display_text(source: String) -> String:
	return source

func _present_step() -> void:
	super._present_step()
	if cancelled or step_index>=sequence_steps().size(): return
	var e: Dictionary=sequence_steps()[step_index]
	if road and e.id!=&"keep_walking": player.set_control(true)
	if e.get("style",DialoguePanel.DialogueStyle.REALITY)==DialoguePanel.DialogueStyle.MANIFESTATION:
		body.add_theme_color_override("font_color",Color("e0a3af"))
		if not reduced_motion: body.material=intrusion_material
	elif e.get("classification")=="HEARD, NO TRIGGER":
		body.add_theme_color_override("font_color",Color("79505c"))
	if e.id==&"phone_message": host.get_node("ExteriorAudio").on_cue(&"phone_message")
	if e.has("text"):
		host.get_node("RoadEffects").present_entry(e)
		body.visible_characters=0
	event_trace.append({"id":e.id,"text":e.get("text",""),"paragraph":e.source_paragraph,"origin":e.get("origin",""),"classification":e.get("classification","cue"),"source_marker":e.get("source_marker",""),"speaker":e.get("speaker",""),"direction":e.get("direction",e.get("delivery","")),"reality":reality.state,"clock":GameClock.get_minutes(),"position":player.position,"environment":host.get_node("SchoolExterior/Map").texture.resource_path})

func _process(delta: float) -> void:
	super._process(delta)
	if phase==Phase.DIALOGUE and body.material==intrusion_material:
		_effect_elapsed+=delta
		intrusion_material.set_shader_parameter("amount",0.14*maxf(0.0,1.0-_effect_elapsed/.25) if not reduced_motion else 0.0)
		intrusion_material.set_shader_parameter("effect_time",_effect_elapsed)

func _next_step() -> void:
	var next: int=step_index+1
	if road and ROAD_BEATS.has(next) and not released_beats.has(next):
		waiting_beat=next
		phase=Phase.WAITING
		body.clear_line()
		panel.hide()
		player.set_control(false)
		return
	super._next_step()

func _physics_process(_delta: float) -> void:
	if road and player.velocity.length()>1.0: _last_walk=player.velocity.normalized()
	if waiting_beat<0 or cancelled or player.global_position.y<1480: return
	var horizontal: float=player.global_position.x-road_origin_x
	if road_direction==0.0 and absf(horizontal)>=16.0: road_direction=signf(horizontal)
	# Both sidewalk directions are valid. Reserve room for the final walking beat.
	var span: float=710.0 if road_direction>0 else maxf(100.0,road_origin_x-202.0)
	var required: float=(float(ROAD_BEATS[waiting_beat])-568.0)/712.0*span
	if road_direction!=0.0 and horizontal*road_direction>=required:
		var beat: int=waiting_beat
		waiting_beat=-1
		released_beats[beat]=true
		beat_trace.append({"step":beat,"position":player.position,"clock":GameClock.get_minutes()})
		player.set_control(true)
		super._next_step()

func _on_stage(id: StringName, direction: String) -> void:
	host.get_node("RoadEffects").on_cue(id,direction)
	host.get_node("ExteriorAudio").on_cue(id)
	if id==&"keep_walking":
		player.set_control(true,_last_walk)

func _on_finished() -> void:
	body.clear_line()
	panel.hide()
	player.set_control(false)
	if not road:
		gate_finished=true
		host.guard.face_direction(Vector2.DOWN)
		host.resolve_encounter(true)
		host.get_node("BoardInteraction").suspended=false
	else:
		host.finish_scene()

func cancel_sequence() -> void:
	if cancelled: return
	cancelled=true
	waiting_beat=-1
	_step_pending=false
	phase=Phase.COMPLETE
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	_clear_held_inputs()
	_restore_text()
	body.interrupt_reveal()
	body.clear_line()
	panel.hide()
	player.set_control(false)
	host.get_node("RoadEffects").clear()
	host.get_node("ExteriorAudio").cancel_presentation()

	# Close the runner before settling reality so no late completion can reveal a line.
	reality.cancel_transition()
	if reality.state==reality.State.MANIFESTED:
		reality.request_normal(&"scene03_cancel")
	for sound: AudioStreamPlayer in host.get_node("TransitionAudio").get_children():
		sound.stop()
