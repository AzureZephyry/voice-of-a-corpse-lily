extends Control
## A few original-font glyphs with stable imperfect registration, not new artwork.
@export var font: Font
@export var heavier_font: Font
var word: String = ""
var font_size: int = 56
var distress: int = 1
var seed_index: int = 0

func configure(text: String, pixels: int, level: int, seed_value: int) -> void:
	word = text
	font_size = pixels
	distress = level + 1
	seed_index = seed_value
	while font_size > 28 and font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x * 1.18 + 34 > size.x:
		font_size -= 2
	queue_redraw()

func _draw() -> void:
	var x: float = 18.0
	var baseline: float = font.get_ascent(font_size) + 22.0
	for i in word.length():
		var glyph: String = word.substr(i, 1)
		var slot: int = posmod(i * 7 + seed_index, 5)
		var offset := Vector2(float(slot - 2), float(posmod(i * 3 + seed_index, 5) - 2)) * float(distress) * (1.8 if seed_index%3==0 else 3.6)
		var selected: Font = heavier_font if slot in [1, 4] else font
		draw_set_transform(Vector2(x,baseline)+offset.round(),float(slot-2)*0.018,Vector2(0.70+float(slot)*0.13,0.65+float(posmod(i+seed_index,4))*0.22))
		draw_string(selected,Vector2.ZERO,glyph,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
		# Uneven, darker duplicate ink gives damaged weight without new glyph assets.
		if slot in [1,4]: draw_string(selected,Vector2(-2,1),glyph,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color(0.55,0.30,0.34,0.6))
		x += selected.get_string_size(glyph,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x * (0.88 if slot in [1,3] else 1.02) + float(slot-2)*float(distress)*1.5
	draw_set_transform(Vector2.ZERO)