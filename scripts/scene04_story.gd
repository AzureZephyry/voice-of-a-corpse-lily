extends Node2D
signal scene_completed
@export var reduced_motion: bool=false
var asleep: bool=false
var dream: bool=false
var completed: bool=false
var cancelled: bool=false
var ending_started: bool=false
var ending_completion_pending: bool=false
var ending_closure_finished: bool=false
var completion_count: int=0
var interaction_history: Array[Dictionary]=[]
var interaction: String="entry"
var echo_time: float=0.0
var cue: StringName
var cue_elapsed: float=0.0
var reveal_busy: bool=false
var _dream_fade: Tween
var _walk: Tween
var trace: Array[Dictionary]=[]
var _music_bus: int=-1
var _panel_vibration: Tween
var _panel_rest_position: Vector2
@onready var player: CharacterBody2D=$Player
@onready var filter: AudioEffectLowPassFilter=$EndingAudio.clarity_filter

func _ready() -> void:
	player.set_physics_process(false)
	player.collision_mask=4
	player.z_index=2
	player.animated_sprite.scale=Vector2(6,6)
	player.get_node("ActorShadow2D").contact_size=Vector2(44,10)
	player.animated_sprite.update_motion(Vector2.LEFT,Vector2.ZERO)
	$RealityGlitch.reduced_motion=reduced_motion
	$Narrative.reduced_motion=reduced_motion
	$Garden.material.set_shader_parameter("reduced_motion",reduced_motion)
	# Scene 04's authored silence overrides persistent gameplay music.
	AudioDirector.stop_music(0.01)
	AudioDirector.stop_ambience(0.01)
	_music_bus=AudioServer.get_bus_index("Music")
	AudioServer.add_bus_effect(_music_bus,filter)
	$Narrative.stage_direction.connect(_on_cue)
	$Narrative.quiz_finished.connect(_finish)
	$RealityPresentation.transition_started.connect(_on_reality_transition_started)
	var compact:=FontVariation.new()
	compact.base_font=load("res://assets/fonts/Pixel handwriting_regular.ttf")
	compact.spacing_top=-26
	compact.spacing_bottom=-20
	$PromptLayer/Prompt.add_theme_font_override("font",compact)
	$PromptLayer/Prompt.add_theme_font_size_override("font_size",26)
	$PromptLayer/Prompt.add_theme_color_override("font_color",Color("f2dfb8"))
	$PromptLayer/Prompt.add_theme_color_override("font_shadow_color",Color.BLACK)
	$PromptLayer/Prompt.add_theme_constant_override("shadow_offset_x",2)
	$PromptLayer/Prompt.add_theme_constant_override("shadow_offset_y",2)
	$PromptLayer.layer=9
	var prompt_box: StyleBoxFlat=$Objectives/Objective.get_theme_stylebox("normal").duplicate()
	prompt_box.content_margin_left=8
	prompt_box.content_margin_right=8
	prompt_box.content_margin_top=4
	prompt_box.content_margin_bottom=4
	$PromptLayer/Prompt.add_theme_stylebox_override("normal",prompt_box)
	$PromptLayer/Prompt.hide()
	$Marker.hide()
	objective("Enter the bedroom")
	player.position=Vector2(640,1000)
	player.animated_sprite.update_motion(Vector2.UP,Vector2.ZERO)
	_update_room_grade()
	$Shadows._process(0.0)

func _on_reality_transition_started(_from: int,_toward: int,_cue: StringName) -> void:
	var panel: Control=$StoryLayer/DialoguePanel
	if is_instance_valid(_panel_vibration):
		_panel_vibration.kill()
	panel.position=_panel_rest_position if _panel_rest_position!=Vector2.ZERO else panel.position
	_panel_rest_position=panel.position
	if reduced_motion or not panel.is_visible_in_tree(): return
	_panel_vibration=create_tween()
	for offset: Vector2 in [Vector2(3,-1),Vector2(-3,1),Vector2(2,1),Vector2(-1,-1),Vector2.ZERO]:
		_panel_vibration.tween_property(panel,"position",_panel_rest_position+offset,0.045)
	_panel_vibration.tween_callback(func(): panel.position=_panel_rest_position)

func _on_cue(id: StringName,_direction: String) -> void:
	cue=id
	cue_elapsed=0.0
	trace.append({"cue":id,"time":GameClock.get_minutes(),"asleep":asleep,"garden":$Garden.visible})
	match id:
		&"entry_medal": player.animated_sprite.update_motion(Vector2.UP,Vector2.ZERO)
		&"bag_bed_phone":
			# The player has reached the bed; no position tween or teleport.
			player.animated_sprite.update_motion(Vector2.LEFT,Vector2.ZERO)
		&"lie_down": player.modulate=Color(0.65,0.65,0.65,1)
		&"sleep":
			asleep=true
			reveal_busy=true
			$SleepCover/Black.show()
			$SleepCover/Black.modulate.a=0
			_walk=create_tween()
			_walk.tween_property($SleepCover/Black,"modulate:a",1.0,1.2)
			_walk.tween_callback(player.hide)
		&"garden_emerges":
			assert(asleep)
			_enter_dream()
		&"music_fades":
			# Silence remains silence: filter the existing bus, never invent a cue.
			filter.cutoff_hz=20000.0
			_begin_final_ending()

func _process(delta: float) -> void:
	if completed or cancelled: return
	_update_room_grade()
	cue_elapsed+=delta
	if false: pass
	elif cue==&"music_fades":
		filter.cutoff_hz=lerpf(20000.0,700.0,clampf(cue_elapsed/3.0,0.0,1.0))

func _finish() -> void:
	if completed or cancelled or ending_completion_pending: return
	ending_completion_pending=true
	if not ending_started: _begin_final_ending()
	while not ending_closure_finished and not cancelled: await get_tree().process_frame
	if cancelled: return
	completed=true
	$Objectives/Objective.finish_and_hide()
	$TimeHUD.hide()
	$EchoLayer.hide()
	completion_count+=1
	player.animated_sprite.pause()
	player.get_node("ActorShadow2D").set_process(false)
	$Shadows.set_process(false)
	$Shadows/Mask.render_target_update_mode=SubViewport.UPDATE_DISABLED
	$StoryLayer/DialoguePanel.hide()
	$Ending/Black.show()
	AudioDirector.stop_music(0.01)
	AudioDirector.stop_ambience(0.01)
	$EndingAudio/Advance.stop()
	_remove_filter()
	scene_completed.emit()

func _begin_final_ending() -> void:
	if ending_started or completed or cancelled: return
	ending_started=true
	reveal_busy=true
	interaction=""
	player.velocity=Vector2.ZERO
	player.set_physics_process(false)
	$Narrative.set_process_input(false)
	$Marker.hide()
	$PromptLayer.hide()
	$Objectives.hide()
	$TimeHUD.hide()
	$EchoLayer.hide()
	$StoryLayer/DialoguePanel.hide()
	_run_ending_closure()

func _run_ending_closure() -> void:
	if not $Eyes.play_closing_sequence(reduced_motion):
		if not $Eyes.is_playing:
			ending_closure_finished=true
			return
		await $Eyes.completed
		if cancelled: return
		if not $Eyes.play_closing_sequence(reduced_motion):
			ending_closure_finished=true
			return
	await $Eyes.completed
	ending_closure_finished=true

func _remove_filter() -> void:
	if _music_bus<0: return
	for i in range(AudioServer.get_bus_effect_count(_music_bus)-1,-1,-1):
		if AudioServer.get_bus_effect(_music_bus,i)==filter: AudioServer.remove_bus_effect(_music_bus,i)

func cancel_sequence() -> void:
	if cancelled: return
	cancelled=true
	$EchoLayer.hide()
	$Objectives.hide()
	$TimeHUD.hide()
	$Marker.hide()
	$PromptLayer.hide()
	if is_instance_valid($Eyes._tween):$Eyes._tween.kill()
	$Eyes.is_playing=false
	$Eyes.clear_awakening_light()
	$Eyes.hide()
	if is_instance_valid(_dream_fade):_dream_fade.kill()
	AudioDirector.stop_music(.1)
	if is_instance_valid(_walk): _walk.kill()
	$Ending/Black.show()
	$Narrative.cancel_sequence()
	$RealityPresentation.cancel_transition()
	$RealityGlitch.finish()
	$EndingAudio/Advance.stop()
	_remove_filter()

func restart_scene() -> void:
	cancel_sequence()
	_restart_settled.call_deferred()

func _restart_settled() -> void:
	await RenderingServer.frame_post_draw
	if is_inside_tree() and get_tree().current_scene==self:
		get_tree().call_deferred("reload_current_scene")

func _exit_tree() -> void:
	_remove_filter()

func objective(title: String) -> void:
	var flags: Array[bool]=[false]
	$Objectives/Objective.present("Objective",PackedStringArray([title]),flags)
	$Objectives/Objective.show()
	$Objectives.show()

func wait_for(target: String) -> void:
	interaction=target
	$Narrative.set_process_input(false)
	objective("Go to bed" if target=="bed" else "Approach and inspect the corpse lily")
	if target=="bed" and $RealityPresentation.state==2: $RealityPresentation.request_normal(&"bed_approach")

func _physics_process(delta: float) -> void:
	if completed or cancelled or ending_started: return
	if interaction=="entry":
		$PromptLayer/Prompt.hide()
		$Marker.hide()
		player.position=player.position.move_toward(Vector2(640,880),150.0*delta)
		player.animated_sprite.update_motion(Vector2.UP,Vector2.UP)
		if player.position.distance_to(Vector2(640,880))<1:
			interaction="medal"
			objective("Notice the medal")
		return
	var can_walk: bool=not reveal_busy and not interaction.is_empty() and $RealityPresentation.state in [0,2]
	var direction: Vector2=Input.get_vector("ui_left","ui_right","ui_up","ui_down") if can_walk else Vector2.ZERO
	var previous: Vector2=player.position
	player.velocity=direction*150.0
	if can_walk: player.move_and_slide()
	player.position=player.position.clamp(Vector2(180,400) if not dream else Vector2(570,540),Vector2(1060,925) if not dream else Vector2(710,830))
	player.animated_sprite.update_motion(direction,player.position-previous)
	var target: Vector2=Vector2(460,315) if interaction=="medal" else Vector2(1040,650) if interaction=="bed" else Vector2(640,480)
	$Marker.position=target
	$Marker.visible=can_walk
	$PromptLayer/Prompt.visible=can_walk and player.position.distance_to(target)<(100 if interaction in ["bed","lily"] else 190)
	$PromptLayer/Prompt.text="[E / Space / Click] " + ("Inspect medal" if interaction=="medal" else "Go to bed" if interaction=="bed" else "Inspect corpse lily")
	$PromptLayer/Prompt.size=$PromptLayer/Prompt.get_combined_minimum_size()
	var anchor: Vector2=Vector2(460,280) if interaction=="medal" else Vector2(1125,350) if interaction=="bed" else Vector2(640,370)
	$PromptLayer/Prompt.position=(Vector2(490,310) if interaction=="medal" else anchor-Vector2($PromptLayer/Prompt.size.x*.5,$PromptLayer/Prompt.size.y+10)).round()
	var hostile: bool=$RealityPresentation.state==2
	$EchoLayer.visible=hostile
	echo_time+=delta
	if hostile:
		var words=["NOTHING","HOLD IT","CARRYING IT","I SAW ALL OF IT","THEY CLAPPED FOR","ANYMORE"]
		for i in $EchoLayer/Echoes.get_child_count():
			var echo=$EchoLayer/Echoes.get_child(i)
			echo.modulate=Color(.9,.32,.4,.78+.18*sin(echo_time*.8+i))
			echo.font.variation_embolden=.65
			if int(echo_time*0.7+i)%3!=echo.get_meta("tick",-1):
				echo.set_meta("tick",int(echo_time*0.7+i)%3)
				echo.configure(words[(int(echo_time*.3)+i)%words.size()],82,2,i if reduced_motion else i+int(echo_time))
	$Garden.material.set_shader_parameter("breath",0.0 if reduced_motion else .012*sin(echo_time*1.4))

func _unhandled_input(event: InputEvent) -> void:
	if interaction in ["","entry"] or not $PromptLayer/Prompt.visible or $Narrative.panel.visible or completed or cancelled or ending_started:return
	var target: Rect2=Rect2(420,260,100,100) if interaction=="medal" else Rect2(1000,500,220,220) if interaction=="bed" else Rect2(555,400,170,160)
	if not preload("res://scripts/interaction_activation.gd").accepts(event,target,$PromptLayer/Prompt.get_global_rect()):return
	get_viewport().set_input_as_handled()
	interaction_history.append({"target":interaction,"position":player.position,"mouse":event is InputEventMouseButton})
	var which=interaction
	interaction=""
	$EndingAudio._on_accepted_advance()
	if which=="bed":$Objectives/Objective.finish_and_hide()
	if which=="medal":$Narrative._on_opening_finished()
	else:
		$Narrative.set_process_input(true)
		$Narrative.released["bag_bed_phone" if which=="bed" else "line_14_1"]=true
		$Narrative._next_step()

func _enter_dream() -> void:
	if not asleep or cancelled:return
	reveal_busy=true
	$SleepCover/Black.modulate.a=1.0
	$SleepCover/Black.show()
	player.collision_mask=0
	if $RealityPresentation.request_manifestation(&"sleep_dream"):
		await $RealityPresentation.transition_finished
	while $RealityPresentation.state in [1,3]:await get_tree().process_frame
	if cancelled:return
	# Prepare one visible actor beneath black before opening the eyes.
	$RealityPresentation.presenter.prepare_dream()
	$Lily.show()
	$Eyes/ColorRect.material.set_shader_parameter("open_amount",0.0)
	$Eyes/ColorRect.modulate.a=1.0
	$Eyes.show()
	await RenderingServer.frame_post_draw
	$SleepCover/Black.hide()
	AudioDirector.play_music(self,2.0,AudioDirector.SOUNDTRACK,true)
	if reduced_motion:
		$Eyes/ColorRect.material.set_shader_parameter("open_amount",0.5)
		$Eyes/WhiteVeil.modulate.a=0.10
		_dream_fade=create_tween()
		_dream_fade.tween_property($Eyes/ColorRect,"modulate:a",0.0,3.5)
		var light_fade:=create_tween()
		light_fade.tween_property($Eyes/WhiteVeil,"modulate:a",0.0,1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await _dream_fade.finished
		$Eyes/WhiteVeil.modulate.a=0.0
		$Eyes.hide()
	else:
		$Eyes.play_wake_up_sequence()
		await $Eyes.completed
	if not cancelled:reveal_busy=false

func _update_room_grade() -> void:
	var hostile: bool=$RealityPresentation.state==2
	var phase=preload("res://scripts/day_phase.gd").sample(GameClock.get_minutes())
	var tones=[Color(.68,.68,.74),Color(.76,.75,.77),Color(.70,.68,.72),Color(.60,.51,.56),Color(.48,.49,.58),Color(.42,.44,.54),Color(.56,.58,.66)]
	$Bedroom.modulate=tones[phase.index].lerp(tones[phase.next],phase.weight) if not hostile else Color.WHITE
