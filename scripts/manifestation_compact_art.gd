extends Control
## Compact collage of the team's original texture regions; no new bitmap assets.
## Header stays 2x. Intact floral silhouettes are redistributed beside it/body.
const ART = preload("res://assets/ui/dialogue/dialogue_dream_world.png")

func _draw() -> void:
	draw_compact(self, Vector2.ZERO, Rect2(-32, 0, 1184, 172))

static func piece(canvas: CanvasItem, source: Rect2, destination: Rect2, clip: Rect2, tint: Color) -> void:
	var cut: Rect2 = destination.intersection(clip)
	if not cut.has_area(): return
	var ratio := source.size / destination.size
	canvas.draw_texture_rect_region(ART, cut, Rect2(source.position + (cut.position-destination.position)*ratio,cut.size*ratio),tint)

static func draw_compact(canvas: CanvasItem, origin: Vector2, clip: Rect2, tint: Color = Color.WHITE) -> void:
	# Clean original body samples, with native corner pixels enlarged uniformly.
	var sx: Array[float] = [50,64,576,590]
	var dx: Array[float] = [0,28,1092,1120]
	for col in 3:
		piece(canvas,Rect2(sx[col],350,sx[col+1]-sx[col],82),Rect2(origin+Vector2(dx[col],66),Vector2(dx[col+1]-dx[col],82)),clip,tint)
	# Existing top/bottom edges and corners, not a repainted rectangle.
	piece(canvas,Rect2(192,325,380,14),Rect2(origin+Vector2(28,38),Vector2(1064,28)),clip,tint)
	piece(canvas,Rect2(64,432,470,12),Rect2(origin+Vector2(28,148),Vector2(1064,24)),clip,tint)
	piece(canvas,Rect2(576,325,14,14),Rect2(origin+Vector2(1092,38),Vector2(28,28)),clip,tint)
	piece(canvas,Rect2(50,432,14,12),Rect2(origin+Vector2(0,148),Vector2(28,24)),clip,tint)
	piece(canvas,Rect2(50,325,14,14),Rect2(origin+Vector2(0,38),Vector2(28,28)),clip,tint)
	piece(canvas,Rect2(576,432,14,12),Rect2(origin+Vector2(1092,148),Vector2(28,24)),clip,tint)
	# Canonical tab, at exactly the approved 264x72 effective header size.
	piece(canvas,Rect2(60,310,132,36),Rect2(origin+Vector2(92,6),Vector2(264,72)),clip,tint)
	# Complete upper/left petal silhouettes around the tab, at uniform 1.5x.
	piece(canvas,Rect2(20,287,92,23),Rect2(origin+Vector2(-24,0),Vector2(138,34.5)),clip,tint)
	piece(canvas,Rect2(20,310,40,54),Rect2(origin+Vector2(-24,34.5),Vector2(60,81)),clip,tint)
	# Complete right floral cluster, at uniform 1.25x, within the same 172px height.
	piece(canvas,Rect2(538,367,90,92),Rect2(origin+Vector2(1035,57),Vector2(112.5,115)),clip,tint)