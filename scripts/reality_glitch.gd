extends CanvasLayer
const ActorMask = preload("res://scripts/screen_actor_mask.gd")
## Passive presentation only. RealityPresentation owns timing, swap and completion.
@export_range(0.3, 0.6, 0.01) var entry_seconds: float = 0.48
@export_range(0.3, 0.6, 0.01) var return_seconds: float = 0.42
@export_range(0.15, 0.4, 0.01) var reduced_seconds: float = 0.22
@export_range(0.0, 32.0, 1.0) var horizontal_pixels: float = 18.0
@export_range(0.0, 4.0, 1.0) var vertical_pixels: float = 2.0
@export_range(4.0, 24.0, 1.0) var band_height: float = 8.0
@export_range(24.0, 160.0, 8.0) var fragment_width: float = 64.0
@export var pattern_seed: int = 113
@export var reduced_motion: bool = false
@export_node_path("AnimatedSprite2D") var protected_actor_path: NodePath
@export_node_path("Control") var protected_hud_path: NodePath
@export var reduced_motion_sources: Array[NodePath] = []

@onready var actor: AnimatedSprite2D = get_node(protected_actor_path)
@onready var hud: Control = get_node_or_null(protected_hud_path) if not protected_hud_path.is_empty() else null
@onready var copy: BackBufferCopy = $WorldCopy
@onready var screen: ColorRect = $Distortion
@onready var material: ShaderMaterial = screen.material
var progress: float = 0.0
var _frame_texture: Texture2D
var _motion_sources: Array[Node] = []

func _ready() -> void:
	for path in reduced_motion_sources:
		var source: Node = get_node_or_null(path)
		if source != null: _motion_sources.append(source)
	finish()

func is_reduced_motion() -> bool:
	if reduced_motion: return true
	for source in _motion_sources:
		if source.get("reduced_motion") == true: return true
	return false

func begin(entering: bool) -> float:
	material.set_shader_parameter("horizontal_pixels", horizontal_pixels)
	material.set_shader_parameter("vertical_pixels", vertical_pixels)
	material.set_shader_parameter("band_height", band_height)
	material.set_shader_parameter("fragment_width", fragment_width)
	material.set_shader_parameter("pattern_seed", float(pattern_seed))
	material.set_shader_parameter("direction", 1.0 if entering else -1.0)
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	render_progress(0.0)
	show()
	return reduced_seconds if is_reduced_motion() else (entry_seconds if entering else return_seconds)

func render_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	material.set_shader_parameter("progress", progress)
	material.set_shader_parameter("reduced_motion", is_reduced_motion())
	_update_protection()
	# Keep the existing translucent clock backing stable, not only its glyphs.
	var rect: Rect2 = hud.get_global_rect().grow(3.0) if hud != null and hud.is_visible_in_tree() else Rect2()
	material.set_shader_parameter("hud_rect", Vector4(rect.position.x, rect.position.y, rect.size.x, rect.size.y))

func _update_protection() -> void:
	_frame_texture = ActorMask.apply(material, actor)

func finish() -> void:
	hide()
	copy.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
	progress = 0.0
	material.set_shader_parameter("progress", 0.0)

func _exit_tree() -> void:
	# No timers, tweens, callbacks, temporary actors or retained frame images.
	if is_instance_valid(copy): copy.copy_mode = BackBufferCopy.COPY_MODE_DISABLED
