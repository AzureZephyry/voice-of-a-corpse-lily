extends Control
## Local, artwork-only strips during the existing transition. No screen capture,
## new dialogue, viewport or world-state request. All canonical ornaments included.
const CompactBlack = preload("res://scripts/manifestation_compact_art.gd")
const WHITE = preload("res://assets/ui/dialogue/dialogue_real_world.png")
var source_manifested: bool = false
var target_manifested: bool = true
var progress: float = 0.0
var offset := Vector2.ZERO
var tear: float = 0.0
var seed_index: int = 0

func render(source: bool, target: bool, value: float, displacement: Vector2, tearing: float, tick: int) -> void:
	source_manifested = source; target_manifested = target; progress = value
	offset = displacement; tear = tearing; seed_index = tick
	show(); queue_redraw()

func _draw() -> void:
	var manifested: bool = source_manifested if progress < 0.5 else target_manifested
	var origin := Vector2(80,708)
	var extent := Vector2(1120,172)
	var strips: int = 14 if manifested else 9
	for i in strips:
		var y: float = floorf(float(i) * extent.y / strips)
		var h: float = ceilf(float(i+1) * extent.y / strips) - y
		var split: float = float(posmod(i*13+seed_index*7,9)-4)/4.0
		var move := offset + Vector2(roundf(split*tear), 0)
		move.x = clampf(move.x, 12.0-origin.x, 1268.0-origin.x-extent.x)
		var destination := Rect2(origin + Vector2(0,y) + move, Vector2(extent.x,h))
		if manifested:
			var shifted_origin := origin + move
			CompactBlack.draw_compact(self, shifted_origin, Rect2(shifted_origin+Vector2(-32,y),Vector2(1184,h)),Color(0.90,0.84,0.85,0.94))
		else:
			_draw_white_strip(destination,Rect2(Vector2(0,y),Vector2(extent.x,h)))

func _draw_white_strip(destination: Rect2, strip: Rect2) -> void:
	# Same 2x NinePatch geometry as the existing white Compact artwork.
	var sx: Array[float] = [50,190,578,590]
	var sy: Array[float] = [310,350,432,444]
	var dx: Array[float] = [0,280,1096,1120]
	var dy: Array[float] = [0,80,148,172]
	for row in 3:
		for col in 3:
			var d := Rect2(Vector2(dx[col],dy[row]),Vector2(dx[col+1]-dx[col],dy[row+1]-dy[row]))
			var cut: Rect2 = d.intersection(strip)
			if not cut.has_area(): continue
			var scale_uv := Vector2((sx[col+1]-sx[col])/d.size.x,(sy[row+1]-sy[row])/d.size.y)
			var source := Rect2(Vector2(sx[col],sy[row])+(cut.position-d.position)*scale_uv,cut.size*scale_uv)
			draw_texture_rect_region(WHITE,Rect2(destination.position+cut.position-strip.position,cut.size),source,Color(0.85,0.82,0.83,0.90))