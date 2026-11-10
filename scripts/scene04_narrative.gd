extends "res://scripts/classroom_quiz.gd"
const Screenplay=preload("res://scripts/scene04_screenplay.gd")
var cancelled: bool=false
var released: Dictionary={}
var event_trace: Array[Dictionary]=[]
func _ready() -> void:
	super._ready()
	body.preserve_source_punctuation=true
	var font: Font=body.get_theme_font("font").duplicate()
	var fallback:=FontVariation.new()
	fallback.base_font=ThemeDB.fallback_font
	fallback.variation_transform=Transform2D(Vector2(.55,0),Vector2(0,.55),Vector2.ZERO)
	font.fallbacks=[fallback]
	body.add_theme_font_override("font",font)
	# Keep the Scene 04 text box's layout stable while Label recalculates wrapped
	# line metrics during typewriter reveal. The panel art and anchors stay authored.
	body.custom_minimum_size=Vector2(0,84)
	body.clip_text=true
	body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	body.set_process_unhandled_key_input(false)
func sequence_steps() -> Array[Dictionary]:
	return Screenplay.STEPS
func display_text(source: String) -> String:
	return source
func _next_step() -> void:
	if cancelled: return
	var next_id: String=sequence_steps()[step_index+1].id if step_index+1<sequence_steps().size() else ""
	if next_id=="music_fades":get_parent().get_node("Objectives/Objective").finish_and_hide()
	if next_id in ["bag_bed_phone","line_14_1"] and not released.has(next_id):
		phase=Phase.WAITING
		panel.hide()
		get_parent().wait_for("bed" if next_id=="bag_bed_phone" else "lily")
		return
	if step_index+1>=sequence_steps().size():
		phase=Phase.COMPLETE
		panel.hide()
		body.clear_line()
		set_process(false)
		set_process_input(false)
		quiz_finished.emit()
		return
	super._next_step()
func _present_step() -> void:
	if cancelled: return
	super._present_step()
	if step_index>=sequence_steps().size(): return
	var e: Dictionary=sequence_steps()[step_index]
	if reality.state==2 and e.has("text"):
		panel.configure_presentation(1,e.speaker,e.layout)
		body.add_theme_color_override("font_color",Color("e0a3af"))
		panel.hint.add_theme_color_override("font_color",Color("ae6a70"))
		panel.speaker.add_theme_color_override("font_color",Color("781f2b"))
	var host: Node=get_parent()
	event_trace.append({"id":e.id,"text":e.get("text",""),"speaker":e.get("speaker",""),"source_marker":e.get("source_marker",""),"classification":e.get("classification","cue"),"reality":reality.state,"asleep":host.asleep,"dream":host.dream,"garden_visible":host.get_node("Garden").visible,"clock":GameClock.get_minutes()})
func cancel_sequence() -> void:
	cancelled=true
	_step_pending=false
	set_process(false)
	set_process_input(false)
	body.clear_line()
	panel.hide()
