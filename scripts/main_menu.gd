extends Control

const STORY_SCENE := "res://scenes/story/connected_story.tscn"
const DESIGN_SIZE := Vector2(640.0, 480.0)
const BUTTON_RECTS := [
	Rect2(246.0, 270.0, 148.0, 44.0),
	Rect2(246.0, 327.0, 148.0, 44.0),
	Rect2(246.0, 384.0, 148.0, 44.0),
]
const MENU_MUSIC_FADE := 0.55
const MENU_MUSIC_GAIN_DB := -6.0

var transitioning: bool = false
var credits_open: bool = false
var _menu_buttons: Array[Button] = []
var _fade_tween: Tween

@onready var artwork: TextureRect = $Artwork
@onready var fade_layer: CanvasLayer = $FadeLayer
@onready var fade_black: ColorRect = $FadeLayer/Black
@onready var credits_view: Control = $CreditsView
@onready var credits_panel: PanelContainer = $CreditsView/CenterPanel
@onready var credits_back: Button = $CreditsView/CenterPanel/Content/Back

func _ready() -> void:
	AudioDirector.play_music(self, 1.25, AudioDirector.SOUNDTRACK, true, MENU_MUSIC_GAIN_DB)
	for i in 3:
		var button := Button.new()
		button.name = ["StartHitArea", "CreditsHitArea", "ExitHitArea"][i]
		button.text = ""
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_stylebox_override("normal", _button_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
		button.add_theme_stylebox_override("hover", _button_style(Color(1, 1, 1, 0.12), Color(1, 1, 1, 0.45)))
		button.add_theme_stylebox_override("pressed", _button_style(Color(0.12, 0.16, 0.23, 0.38), Color(1, 1, 1, 0.65)))
		button.add_theme_stylebox_override("focus", _button_style(Color(0, 0, 0, 0), Color(1, 1, 1, 0.9)))
		button.pressed.connect(_on_menu_button_pressed.bind(i))
		add_child(button)
		_menu_buttons.append(button)
	_layout_buttons()
	get_viewport().size_changed.connect(_layout_buttons)
	get_viewport().size_changed.connect(_layout_credits)
	credits_back.pressed.connect(_hide_credits)
	credits_back.add_theme_stylebox_override("normal", _button_style(Color(0.16, 0.20, 0.28, 0.98), Color(0.75, 0.81, 0.9, 0.95)))
	credits_back.add_theme_stylebox_override("hover", _button_style(Color(0.25, 0.31, 0.42, 1), Color(0.9, 0.94, 1, 1)))
	credits_back.add_theme_stylebox_override("pressed", _button_style(Color(0.1, 0.14, 0.2, 1), Color(1, 1, 1, 1)))
	credits_back.add_theme_stylebox_override("focus", _button_style(Color(0.16, 0.20, 0.28, 0.98), Color(1, 1, 1, 1)))
	fade_black.modulate.a = 0.0
	fade_black.hide()
	_menu_buttons[0].grab_focus.call_deferred()

func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2 if border.a > 0.0 else 0)
	style.set_corner_radius_all(8)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	return style

func _layout_buttons() -> void:
	if not is_node_ready():
		return
	var viewport := get_viewport_rect().size
	var scale_factor := minf(viewport.x / DESIGN_SIZE.x, viewport.y / DESIGN_SIZE.y)
	var displayed_size := DESIGN_SIZE * scale_factor
	var origin := (viewport - displayed_size) * 0.5
	artwork.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	artwork.position = origin
	artwork.size = displayed_size
	for i in _menu_buttons.size():
		var rect: Rect2 = BUTTON_RECTS[i]
		_menu_buttons[i].position = origin + rect.position * scale_factor
		_menu_buttons[i].size = rect.size * scale_factor

func _on_menu_button_pressed(index: int) -> void:
	if transitioning or credits_open:
		return
	match index:
		0: _start_story()
		1: _show_credits()
		2: get_tree().quit()

func _start_story() -> void:
	if transitioning:
		return
	transitioning = true
	for button in _menu_buttons:
		button.disabled = true
	fade_black.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_black.modulate.a = 0.0
	fade_black.show()
	AudioDirector.stop_music(MENU_MUSIC_FADE)
	_fade_tween = create_tween()
	_fade_tween.tween_property(fade_black, "modulate:a", 1.0, MENU_MUSIC_FADE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _fade_tween.finished
	if not is_inside_tree():
		return
	GameState.reset_session()
	GameClock.set_time(6, 30)
	var error: Error = get_tree().change_scene_to_file(STORY_SCENE)
	if error != OK:
		AudioDirector.play_music(self, 0.4, AudioDirector.SOUNDTRACK, true, MENU_MUSIC_GAIN_DB)
		_fade_tween = create_tween()
		_fade_tween.tween_property(fade_black, "modulate:a", 0.0, 0.35)
		await _fade_tween.finished
		fade_black.hide()
		fade_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for button in _menu_buttons:
			button.disabled = false
		transitioning = false
		_menu_buttons[0].grab_focus()
		push_error("Could not open connected story: %s" % error_string(error))

func _show_credits() -> void:
	credits_open = true
	for button in _menu_buttons:
		button.hide()
	credits_view.show()
	_layout_credits()
	credits_back.grab_focus.call_deferred()

func _unhandled_key_input(event: InputEvent) -> void:
	if not credits_open or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_hide_credits()

func _layout_credits() -> void:
	if not is_node_ready(): return
	var viewport := get_viewport_rect().size
	var scale_factor := minf(viewport.x / 1280.0, viewport.y / 960.0)
	var panel_size := Vector2(600.0, 760.0)
	credits_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	credits_panel.size = panel_size
	credits_panel.scale = Vector2.ONE * scale_factor
	credits_panel.position = (viewport - panel_size * scale_factor) * 0.5

func _hide_credits() -> void:
	if not credits_open:
		return
	credits_open = false
	credits_view.hide()
	for button in _menu_buttons:
		button.show()
	_menu_buttons[0].grab_focus.call_deferred()
