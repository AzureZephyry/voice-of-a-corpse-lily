extends Node
## World-only vignette and source-derived intrusive echoes; cues never print raw captions.
var target_vignette: float=0.0
@onready var host: Node=get_parent()
@onready var echoes: Node=host.get_node("EchoLayer/Echoes")
@onready var vignette: ShaderMaterial=host.get_node("RoadVignette/Edges").material

func present_entry(entry: Dictionary) -> void:
	var pair: int=int(entry.get("pair",0)) if entry.get("classification")=="HEARD" else 0
	for i in echoes.get_child_count():
		var echo=echoes.get_child(i)
		echo.visible=pair>0
		if pair>0: echo.configure((["NOT FUNNY","NOTHING"] if pair==7 else ["SMALL","WHAT I WAS"])[i],56,0,i*7)

func on_cue(id: StringName,_direction: String) -> void:
	for echo in echoes.get_children(): echo.hide()
	if id==&"road_atmosphere": target_vignette=.28
	# Unsupported tricycle/vendor, wind and natural vegetation performances remain
	# ordered production cues. Missing assets are not replaced with captions or props.

func _process(delta: float) -> void:
	var current: float=vignette.get_shader_parameter("strength")
	vignette.set_shader_parameter("strength",move_toward(current,target_vignette,delta*.07))

func clear() -> void:
	set_process(false)
	target_vignette=0.0
	vignette.set_shader_parameter("strength",0.0)
	for echo in echoes.get_children(): echo.hide()
