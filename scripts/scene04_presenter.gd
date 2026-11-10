extends Node
## Bedroom reality is owned by RealityPresentation; dream location requires sleep.
const NORMAL=preload("res://assets/environments/bedroom/bedroom_normal.png")
const MANIFESTED=preload("res://assets/environments/bedroom/bedroom_manifested.png")
@onready var host: Node=get_parent()
func can_present_manifested() -> bool:
	return true
func present_manifested() -> void:
	if host.asleep:
		prepare_dream()
	else:
		host.get_node("Bedroom").texture=MANIFESTED
		host.get_node("Bedroom").material.set_shader_parameter("manifested",true)
		host.get_node("Bedroom").modulate=Color.WHITE
func present_normal() -> void:
	if not host.dream:
		host.get_node("Bedroom").texture=NORMAL
		host.get_node("Bedroom").material.set_shader_parameter("manifested",false)
		host.get_node("Bedroom").modulate=Color(0.72,0.72,0.78,1)

func prepare_dream() -> void:
	host.dream=true
	host.get_node("Bedroom").hide()
	host.get_node("Garden").show()
	host.get_node("Garden").material.set_shader_parameter("progress",1.0)
	host.player.position=Vector2(640,800)
	host.player.modulate=Color.WHITE
	host.player.show()
