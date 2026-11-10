extends Node
## Standalone debug-build controls, not screenplay events or shipping bindings.
@export var enabled: bool = true
@export_node_path("Node") var reality_path: NodePath
@export_node_path("CanvasLayer") var effect_path: NodePath
@onready var reality: Node = get_node(reality_path)
@onready var effect: CanvasLayer = get_node(effect_path)


func _unhandled_key_input(event: InputEvent) -> void:
	if not enabled or not OS.is_debug_build() or not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_R:
		if reality.state == reality.State.NORMAL:
			reality.request_manifestation(&"hallway_debug")
		elif reality.state == reality.State.MANIFESTED:
			reality.request_normal(&"hallway_debug")
		get_viewport().set_input_as_handled()
	elif event.physical_keycode == KEY_M:
		# Change accessibility policy only between transitions.
		if reality.state in [reality.State.NORMAL, reality.State.MANIFESTED]:
			effect.reduced_motion = not effect.reduced_motion
		get_viewport().set_input_as_handled()
