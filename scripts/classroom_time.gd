extends Node
## Scene 01 keeps session time running through movement locks and dialogue.
@onready var hud: CanvasLayer = get_node("../TimeHUD")

func _ready() -> void:
	hud.set_gameplay_active(true)
	hud.show()
