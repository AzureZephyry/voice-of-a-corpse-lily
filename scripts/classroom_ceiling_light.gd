extends Node2D
## Independent source state; current_intensity includes transitions and electrical dips.
@export var enabled: bool = true
@export_range(0.0,2.0,0.01) var intensity: float = 0.70
@export var color: Color = Color(1.0,0.95,0.86)
## Provisional projection: the middle seating band is at y=628, separate from
## the attachment at y=21. Wayne should confirm this ceiling-to-floor projection.
@export var floor_projection := Vector2(0,607)
@export var emitter_height: float = 360.0
@export var reach := Vector2(215,200)
@export_range(0.1,4.0,0.1) var falloff: float = 1.5
@export var transition_seconds: float = 1.8
@export var flicker_enabled: bool = true
@export var show_provisional_fixture: bool = true
var manual_override: bool = false
var override_intensity: float = 0.0
var current_intensity: float = 0.0
var _level: float = 0.0
var floor_position: Vector2:
	get: return position+floor_projection

func _draw() -> void:
	# PROVISIONAL scene primitives only. Replace with Wayne's final shade artwork.
	if not show_provisional_fixture:return
	draw_rect(Rect2(-23,0,46,10),Color("25272a"))
	draw_rect(Rect2(-2,8,4,10),Color("37383a"))
	var shade:=PackedVector2Array([Vector2(-12,15),Vector2(12,15),Vector2(26,35),Vector2(26,39),Vector2(-26,39),Vector2(-26,35)])
	draw_colored_polygon(shade,Color("34363b"))
	draw_polyline(PackedVector2Array([Vector2(-26,35),Vector2(-12,15),Vector2(12,15),Vector2(26,35)]),Color("17191c"),2.0)
	draw_line(Vector2(-9,18),Vector2(-20,33),Color("505158"),2.0)
	var underside:=PackedVector2Array([Vector2(-25,38),Vector2(-18,35),Vector2(18,35),Vector2(25,38),Vector2(18,42),Vector2(-18,42)])
	var glow:=Color("4b4840").lerp(color*0.9,clampf(current_intensity/0.70,0,1))
	draw_colored_polygon(underside,glow)
	draw_line(Vector2(-26,39),Vector2(-18,43),Color("191b1e"),2.0)
	draw_line(Vector2(-18,43),Vector2(18,43),Color("191b1e"),2.0)

func override_brightness(value: float, seconds: float = 1.8) -> void:
	manual_override = true
	override_intensity = clampf(value,0.0,2.0)
	transition_seconds = maxf(seconds,0.01)

func restore_automatic(seconds: float = 1.8) -> void:
	# Restore the normal always-on policy, not a time-of-day switch.
	manual_override = false
	transition_seconds = maxf(seconds,0.01)

func update_source(delta: float, automatic: float, dip: float) -> void:
	var target: float = (override_intensity if manual_override else intensity*automatic) if enabled else 0.0
	_level = lerpf(_level,target,1.0-exp(-4.0*delta/maxf(transition_seconds,0.01)))
	current_intensity = _level*(1.0-dip)
	queue_redraw()
