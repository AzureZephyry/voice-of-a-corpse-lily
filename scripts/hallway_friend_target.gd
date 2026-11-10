extends "res://scripts/overworld_interactable.gd"
## Reuses target range/bounds, while the canonical narrative owns all dialogue.
@export var display_name: String = ""
@export_node_path("Node") var narrative_path: NodePath = ^"../../../Narrative"
@onready var narrative: Node = get_node(narrative_path)

func available() -> bool:
	return in_range and not narrative.encounter_started and narrative.stage == narrative.Stage.ENCOUNTER
