extends Label
@onready var checklist_boxes: Array[Panel]=[$ScheduleCheck,$IDCheck,$MedalCheck]
var _current: Dictionary={}
var _pending: Dictionary={}
var _holding: bool=false
var _hide_after: bool=false
func present(title: String,entries: PackedStringArray,completed: Array[bool]) -> void:
	var data={"title":title,"entries":entries,"flags":completed.duplicate()}
	if entries.is_empty():data={"title":"Objective","entries":PackedStringArray([title]),"flags":[false]}
	if _current.is_empty():_apply(data)
	elif _current.title==data.title and _current.entries==data.entries:
		if not _holding:_apply(data)
	else:
		_pending=data
		_hide_after=false
		complete_current()
func complete_current() -> void:
	if _holding or _current.is_empty():return
	if _current.get("done",false):
		if not _pending.is_empty():
			var data=_pending;_pending={};_apply(data)
		elif _hide_after:hide()
		return
	_current.done=true
	_holding=true
	_current.flags=[]
	for entry in _current.entries:_current.flags.append(true)
	_render(_current.title,_current.entries,_current.flags)
	show()
	await get_tree().create_timer(.65,false).timeout
	if not is_inside_tree():return
	_holding=false
	if not _pending.is_empty():
		var data=_pending;_pending={};_apply(data)
	elif _hide_after:hide()
func finish_and_hide() -> void:
	_pending={}
	_hide_after=true
	complete_current()
func _apply(data: Dictionary) -> void:
	_current=data
	_render(data.title,data.entries,data.flags)
func _render(title: String,entries: PackedStringArray,completed: Array) -> void:
	var lines: PackedStringArray = [title]
	for entry in entries:
		lines.append("   " + entry)
	text = "\n".join(lines)
	size.y = maxf(66.0, get_combined_minimum_size().y)
	var line_height: float = get_line_height()
	var line_step: float = line_height + get_theme_constant("line_spacing")
	for index in checklist_boxes.size():
		var checkbox := checklist_boxes[index]
		checkbox.visible = index < entries.size()
		checkbox.position = Vector2(14, 8 + (index + 1) * line_step + (line_height - 12) * 0.5)
		checkbox.get_node("Fill").visible = index < completed.size() and completed[index]
