extends RefCounted
## Dialogue/UI consume input first; callers must supply the selected visible prompt.
static var _last_accept_frame: int=-10
static func accepts(event: InputEvent,_target: Rect2,prompt: Rect2) -> bool:
	if not prompt.has_area() or Engine.get_process_frames()<=_last_accept_frame+1:return false
	var accepted: bool=false
	if event is InputEventKey:accepted=event.pressed and not event.echo and event.is_action(&"dialogue_advance")
	elif event is InputEventMouseButton:
		var viewport: Rect2=Engine.get_main_loop().root.get_visible_rect()
		accepted=event.pressed and event.button_index==MOUSE_BUTTON_LEFT and viewport.has_point(event.position)
	if accepted:_last_accept_frame=Engine.get_process_frames()
	return accepted
