extends CanvasLayer
## Open the eyes with a hesitant blink.
signal completed

@export var auto_start: bool = true
@export var free_on_finish: bool = true
## Temporary timing: 3.5 seconds with the default settings.
@export_range(0.0, 3.0, 0.05) var initial_delay_seconds: float = 0.15
@export_range(0.1, 8.0, 0.1) var playback_speed: float = 1.0

@onready var color_rect: ColorRect = $ColorRect
@onready var white_veil: ColorRect = $WhiteVeil
@onready var closing_shade: ColorRect = $ClosingShade
var is_playing: bool = false
var is_closing: bool = false
var _tween: Tween
var _light_tween: Tween

func _ready() -> void:
	color_rect.material.set_shader_parameter("open_amount", 0.0)
	if auto_start:
		play_wake_up_sequence()

func play_wake_up_sequence() -> bool:
	if is_playing:
		return false
	is_playing = true
	color_rect.material.set_shader_parameter("open_amount", 0.0)
	white_veil.modulate.a = 0.0
	closing_shade.modulate.a = 0.0
	color_rect.modulate.a = 1.0
	show()
	_tween = create_tween().set_speed_scale(playback_speed)
	_tween.tween_interval(initial_delay_seconds)
	_tween.tween_property(color_rect, "material:shader_parameter/open_amount", 0.28, 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_light_tween = create_tween().set_speed_scale(playback_speed)
	_light_tween.tween_interval(initial_delay_seconds)
	_light_tween.tween_property(white_veil, "modulate:a", 0.16, 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_light_tween.tween_property(white_veil, "modulate:a", 0.0, 2.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(0.30)
	_tween.tween_property(color_rect, "material:shader_parameter/open_amount", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(0.12)
	_tween.tween_property(color_rect, "material:shader_parameter/open_amount", 1.0, 1.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(_finish)
	return true

func play_closing_sequence(reduced_motion: bool = false) -> bool:
	if is_playing:
		return false
	is_playing = true
	is_closing = true
	white_veil.modulate.a = 0.0
	closing_shade.modulate.a = 0.0
	color_rect.modulate.a = 1.0
	color_rect.material.set_shader_parameter("open_amount", 1.0)
	show()
	_tween = create_tween()
	if reduced_motion:
		_tween.tween_property(closing_shade, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		_tween.tween_property(color_rect, "material:shader_parameter/open_amount", 0.0, 2.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_tween.parallel().tween_property(closing_shade, "modulate:a", 0.78, 2.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(_finish_closing)
	return true

func _finish_closing() -> void:
	white_veil.modulate.a = 0.0
	closing_shade.modulate.a = 1.0
	color_rect.modulate.a = 1.0
	color_rect.material.set_shader_parameter("open_amount", 0.0)
	is_playing = false
	is_closing = false
	completed.emit()

func _finish() -> void:
	color_rect.material.set_shader_parameter("open_amount", 1.0)
	white_veil.modulate.a = 0.0
	is_playing = false
	hide()
	completed.emit()
	if free_on_finish:
		queue_free()

func clear_awakening_light() -> void:
	if is_instance_valid(_light_tween):
		_light_tween.kill()
	white_veil.modulate.a = 0.0
