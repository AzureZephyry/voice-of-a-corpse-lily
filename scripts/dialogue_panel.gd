extends Control
signal accepted_line_advanced
var _advance_sound_frame: int = -1
var _art_bounds: Dictionary = {}

## Called only after the narrative host accepts a completed-line advance.
func notify_accepted_advance(has_following_line: bool) -> void:
	if not has_following_line or not is_visible_in_tree() or not body.is_active or body.is_typing: return
	var frame: int = Engine.get_process_frames()
	if frame == _advance_sound_frame: return
	_advance_sound_frame = frame
	accepted_line_advanced.emit()

## Full-image skins selected by Albert's world, independently of interaction type.
## Panel-only FontVariations trim this font's oversized vertical metrics; the TTF is unchanged.

enum World { DREAM, REAL }
enum Layout { STANDARD, COMPACT }
enum DialogueStyle { REALITY, MANIFESTATION }

@export var presentation: Layout = Layout.STANDARD:
	set(value):
		presentation = value
		if is_node_ready():
			_layout_artwork()

## Compact-only option; Standard artwork and layout remain unchanged.
@export var show_nameplate: bool = true:
	set(value):
		show_nameplate = value
		if is_node_ready():
			_layout_artwork()

const DREAM_ART = preload("res://assets/ui/dialogue/dialogue_dream_world.png")
const REAL_ART = preload("res://assets/ui/dialogue/dialogue_real_world.png")

@export var world: World = World.DREAM:
	set(value):
		world = value
		if is_node_ready():
			_apply_world()

@export var speaker_name: String = "":
	set(value):
		speaker_name = value
		if is_node_ready():
			$Speaker.text = speaker_name

@onready var artwork: TextureRect = $Artwork
@onready var compact_artwork: NinePatchRect = $CompactArtwork
@onready var manifestation_artwork: NinePatchRect = $ManifestationArtwork
@onready var body: Label = $Margin/Content/Body
@onready var hint: Label = $Margin/Content/Hint
@onready var speaker: Label = $Speaker

func _ready() -> void:
	add_to_group("dialogue_panels")
	resized.connect(_layout_artwork)
	speaker.text = speaker_name
	_apply_world()

func _apply_world() -> void:
	var dreaming: bool = world == World.DREAM
	artwork.texture = DREAM_ART if dreaming else REAL_ART
	body.add_theme_color_override("font_color", Color("#fff9ed") if dreaming else Color("#151d22"))
	hint.add_theme_color_override("font_color", Color("#c4c9cf") if dreaming else Color("#515a64"))
	# Both supplied name tabs are light, including the Dream World tab.
	speaker.add_theme_color_override("font_color", Color("#252b32"))
	_layout_artwork()


## Explicit skin/identity selection; legacy world callers keep their existing API.
## Unknown manifestation voices never inherit a previous speaker or an empty tab.
func configure_presentation(style: DialogueStyle, identity: String, layout: Layout = Layout.COMPACT) -> void:
	world = World.DREAM if style == DialogueStyle.MANIFESTATION else World.REAL
	presentation = layout
	show_nameplate = true
	speaker_name = "???" if style == DialogueStyle.MANIFESTATION and identity.strip_edges().is_empty() else identity

func _layout_artwork() -> void:
	if not is_node_ready() or artwork.texture == null or size.x <= 0.0:
		return
	var source: Vector2 = artwork.texture.get_size()
	# Source skins are static. Repeated GPU readback here stalls every line change.
	if not _art_bounds.has(artwork.texture):
		_art_bounds[artwork.texture] = Rect2(artwork.texture.get_image().get_used_rect())
	var visible_area: Rect2 = _art_bounds[artwork.texture]
	if not visible_area.has_area():
		return
	var compact: bool = presentation == Layout.COMPACT
	var black_compact: bool = compact and world == World.DREAM
	if not compact and not is_equal_approx(offset_bottom,-80.0): offset_bottom = -80.0
	artwork.visible = not compact
	var nameless: bool = compact and not black_compact and not show_nameplate
	compact_artwork.visible = compact and not black_compact and not nameless
	manifestation_artwork.visible = black_compact
	$NamelessLeft.visible = nameless
	$NamelessRight.visible = nameless
	speaker.visible = not nameless
	body.add_theme_font_size_override("font_size", 40 if black_compact else 48)
	if compact:
		# Both Compact skins occupy exactly 172px including their ornamentation.
		if not is_equal_approx(offset_bottom, -80.0): offset_bottom = -80.0
		if not is_equal_approx(size.y, 172.0): offset_top = offset_bottom - 172.0
		if black_compact:
			manifestation_artwork.texture = null
			manifestation_artwork.scale = Vector2.ONE
			manifestation_artwork.position = Vector2.ZERO
			manifestation_artwork.size = Vector2(size.x,172)
			manifestation_artwork.queue_redraw()
			$Margin.position = Vector2(40,78)
			$Margin.size = Vector2(950,82)
			speaker.position = Vector2(102,14)
			speaker.size = Vector2(244,56)
			return
		compact_artwork.texture = artwork.texture
		compact_artwork.region_rect = visible_area
		compact_artwork.position = Vector2.ZERO
		compact_artwork.scale = Vector2(2, 2)
		compact_artwork.size = Vector2(size.x / 2.0, 86)
		if nameless:
			# Reuse the clean right half twice; mirroring supplies the left corners.
			# Native edge pixels stay at 2x. No name-tab pixels are sampled.
			for half: NinePatchRect in [$NamelessLeft, $NamelessRight]:
				half.texture = artwork.texture
				half.region_rect = Rect2(320, 327, 270, 117)
				half.size = Vector2(size.x / 4.0, 86)
				half.position = Vector2(size.x / 2.0, 0)
			$NamelessLeft.scale = Vector2(-2, 2)
			$NamelessRight.scale = Vector2(2, 2)
			$Margin.position = Vector2(28, 24)
			$Margin.size = Vector2(size.x - 56, 136)
			return
		$Margin.position = Vector2(28, 68)
		$Margin.size = Vector2(size.x - 56, 92)
		speaker.position = Vector2(32, 6)
		speaker.size = Vector2(244, 56)
		return
	var scale_factor: float = size.x / visible_area.size.x
	var artwork_height: float = visible_area.size.y * scale_factor
	if not is_equal_approx(size.y, artwork_height):
		offset_top = offset_bottom - artwork_height
	# Keep the complete texture; transparent canvas does not occupy dialogue space.
	artwork.anchor_right = 0.0
	artwork.anchor_bottom = 0.0
	artwork.position = -visible_area.position * scale_factor
	artwork.size = source * scale_factor
	# Safe areas in the approved 640 x 480 exports, before transparent padding.
	var body_rect := Rect2(64, 346, 460, 82) if world == World.DREAM else Rect2(64, 344, 510, 84)
	var tab_rect := Rect2(66, 313, 122, 28)
	$Margin.position = (body_rect.position - visible_area.position) * scale_factor
	$Margin.size = body_rect.size * scale_factor
	speaker.position = (tab_rect.position - visible_area.position) * scale_factor
	speaker.size = tab_rect.size * scale_factor
