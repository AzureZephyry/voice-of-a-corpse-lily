extends Node
## One presentation authority. The scene adapter owns assets, never story text.
signal state_changed(state: State)
signal transition_started(from: State, toward: State, cue: StringName)
signal transition_finished(state: State, cue: StringName)
enum State { NORMAL, GLITCH_IN, MANIFESTED, GLITCH_OUT }
@export_node_path("Node") var presenter_path: NodePath
@export_node_path("CanvasLayer") var transition_effect_path: NodePath
@onready var presenter: Node = get_node(presenter_path)
@onready var effect: CanvasLayer = get_node_or_null(transition_effect_path) if not transition_effect_path.is_empty() else null
var state: State = State.NORMAL
var _target: State = State.NORMAL
var _cue: StringName
var _elapsed: float = 0.0
var _duration: float = 0.0
var _swapped: bool = false
var _draw_checkpoint: int = -1
var _generation: int = 0

func _ready() -> void:
	set_process(false)

func request_manifestation(cue: StringName = &"") -> bool:
	# Busy and redundant requests are rejected, never queued or replayed later.
	if state != State.NORMAL or not presenter.can_present_manifested(): return false
	_begin(State.MANIFESTED, cue)
	return true

func request_normal(cue: StringName = &"") -> bool:
	if state != State.MANIFESTED: return false
	_begin(State.NORMAL, cue)
	return true

func _begin(target: State, cue: StringName) -> void:
	var previous: State = state
	_target = target
	_cue = cue
	_elapsed = 0.0
	_swapped = false
	_draw_checkpoint = -1
	_generation += 1
	var generation: int = _generation
	state = State.GLITCH_IN if target == State.MANIFESTED else State.GLITCH_OUT
	if effect != null:
		_duration = effect.begin(target == State.MANIFESTED)
		set_process(true)
	else:
		_finish_without_effect.call_deferred(generation)
	state_changed.emit(state)
	if generation == _generation:
		transition_started.emit(previous, target, cue)

func _process(delta: float) -> void:
	# Render a fully covered source frame, then a covered destination frame.
	# A slow frame cannot jump past the mask and expose an instantaneous art swap.
	if _draw_checkpoint >= 0:
		effect.render_progress(0.5)
		if Engine.get_frames_drawn() <= _draw_checkpoint: return
		if not _swapped:
			_apply_target()
			_draw_checkpoint = Engine.get_frames_drawn()
			return
		_draw_checkpoint = -1
	_elapsed += delta
	var progress: float = minf(_elapsed / _duration, 1.0)
	if not _swapped and progress >= 0.5:
		_elapsed = _duration * 0.5
		progress = 0.5
		_draw_checkpoint = Engine.get_frames_drawn()
	effect.render_progress(progress)
	if progress >= 1.0: _complete()

func _apply_target() -> void:
	if _target == State.MANIFESTED: presenter.present_manifested()
	else: presenter.present_normal()
	_swapped = true

func _complete() -> void:
	var completed: State = _target
	var cue: StringName = _cue
	set_process(false)
	_draw_checkpoint = -1
	if effect != null: effect.finish()
	state = completed
	state_changed.emit(state)
	transition_finished.emit(completed, cue)

## Cancel only the VFX, settling the already-authorized target exactly once.
## This avoids leaving the narrative waiting for a completion that never arrives.
func cancel_transition() -> bool:
	if state not in [State.GLITCH_IN, State.GLITCH_OUT]: return false
	_generation += 1
	if not _swapped: _apply_target()
	_complete()
	return true

func _finish_without_effect(generation: int) -> void:
	if generation != _generation or not is_inside_tree(): return
	_apply_target()
	_complete()

func _on_manifestation_requested(cue: StringName) -> void:
	request_manifestation(cue)

func _exit_tree() -> void:
	_generation += 1
	set_process(false)
	if is_instance_valid(effect): effect.finish()
