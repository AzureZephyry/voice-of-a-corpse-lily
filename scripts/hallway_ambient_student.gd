extends "res://scripts/npc_character.gd"
## Authored floor routes, short waits and priority yielding; no story or input.
@export var route_left: float = 150.0
@export var route_right: float = 3700.0
@export var initial_direction: float = 1.0
@export var initial_wait: float = 0.0
@export var wait_seconds: float = 2.0
@export var idle_only: bool = false
@export var idle_facing: Vector2 = Vector2.UP
@export var schedule_seed: int = 0
var lane_y: float
var home: Vector2
var toward_right: bool
var waiting: float
var detailed: bool = false
var arrivals: int = 0
var yields: int = 0
var _idle_turn: int = 0
var _yielding: bool = false
var _yield_time: float = 0.0
var _yield_y: float

func _ready() -> void:
	set_physics_process(false)
	lane_y = position.y
	home = position
	toward_right = initial_direction > 0
	waiting = initial_wait
	animated_sprite.update_motion(idle_facing if idle_only else Vector2(initial_direction,0), Vector2.ZERO)
	animated_sprite.set_frame_and_progress(schedule_seed % 4, fmod(float(schedule_seed) * .173, 1.0))
	animated_sprite.pause()

func tick(delta: float, active: bool, player: CharacterBody2D, neighbors: Array) -> void:
	if active != detailed:
		detailed = active
		if detailed: animated_sprite.play()
		else: animated_sprite.pause()
	waiting = maxf(0.0, waiting-delta)
	_yield_time = maxf(0.0, _yield_time-delta)
	var sign_x: float = 1.0 if toward_right else -1.0
	var target := Vector2(route_right if toward_right else route_left, lane_y)
	if idle_only: target = home
	var yielding: bool = false
	var following: bool = false
	if active:
		var relative: Vector2 = player.global_position - global_position
		if absf(relative.x) < 84.0 and absf(relative.y) < 48.0:
			_yield_y = clampf(lane_y + (-62.0 if relative.y >= 0 else 62.0), 382.0, 778.0)
			_yield_time = .9
		if _yield_time > 0.0:
			target.y = _yield_y
			if idle_only: target.x = home.x + (-24.0 if relative.x >= 0 else 24.0)
			yielding = true
		for other in neighbors:
			if other == self or not other.detailed: continue
			var gap: Vector2 = other.global_position - global_position
			if absf(gap.y) >= 32.0 or gap.x * sign_x <= 0.0 or absf(gap.x) > 86.0: continue
			if not idle_only and (other.idle_only or other.toward_right != toward_right):
				target.y = clampf(lane_y + sign_x * 36.0, 382.0, 778.0)
			elif absf(gap.x) < 48.0:
				following = true
	if yielding and not _yielding: yields += 1
	_yielding = yielding
	var difference := target - position
	var direction := difference.normalized()
	if active and not idle_only:
		direction = Vector2(sign_x, clampf(difference.y*.08,-1.5,1.5)).normalized()
		if yielding and absf(difference.y) > 8.0:
			direction = Vector2(sign_x*.15, signf(difference.y)).normalized()
	if (waiting > 0.0 or following) and not yielding: direction = Vector2.ZERO
	if difference.length_squared() < 4.0:
		direction = Vector2.ZERO
		if idle_only:
			if waiting <= 0.0:
				_idle_turn += 1
				waiting = wait_seconds + float((_idle_turn+schedule_seed)%4)
				if active: face_direction(idle_facing.rotated(float((_idle_turn%3)-1)*PI/4.0))
		elif waiting <= 0.0:
			toward_right = not toward_right
			waiting = wait_seconds + float((arrivals+schedule_seed)%3)*.6
			arrivals += 1
	if active:
		set_move_direction(direction)
		super._physics_process(delta)
	else:
		# This bounded coarse step is only used beyond a generous camera margin.
		position = position.move_toward(target, movement_speed * delta) if not direction.is_zero_approx() else position
