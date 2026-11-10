extends Node
## Reuses ActorShadow2D and the shared red-cast/green-contact mask contract.
var prototype_enabled: bool=true
var sun_direction:=Vector2.DOWN
var length_ratio: float=.55
var sun_opacity: float=.3
var _last_projection:=Vector2(INF,INF)
func _ready() -> void:
 $Mask.world_2d=World2D.new()
 $Receiver.texture=$Mask.get_texture()
 add_to_group("actor_shadow_receiver")
func get_actor_shadow_map() -> Sprite2D:return $Map
func attach_actor_shadow(visual: Node2D) -> void:
 visual.reparent($Mask/Coordinates,false)
 request_actor_shadow_redraw()
func request_actor_shadow_redraw() -> void:$Mask.render_target_update_mode=SubViewport.UPDATE_ONCE
func _process(_delta: float) -> void:
 var host=get_parent()
 var minute: float=GameClock.get_minutes()
 var phase=preload("res://scripts/day_phase.gd").sample(minute)
 var strengths=[.32,.40,.32,.20,.04,0.0,.12]
 var daylight: float=lerpf(strengths[phase.index],strengths[phase.next],phase.weight)
 var palette=[Color(.44,.55,.62),Color(.67,.70,.64),Color(.63,.53,.42),Color(.50,.29,.25),Color(.20,.23,.34),Color(.10,.13,.22),Color(.29,.35,.48)]
 var pane: Color=palette[phase.index].lerp(palette[phase.next],phase.weight)
 host.get_node("Bedroom").material.set_shader_parameter("pane_color",pane)
 host.get_node("WindowSpill").material.set_shader_parameter("light_color",pane.lightened(.2))
 var skew: float=sin(minute/1440.0*TAU)*.25
 var hostile: bool=host.dream or host.get_node("RealityPresentation").state==2
 sun_direction=((host.player.position-Vector2(678,300)).normalized()+Vector2(skew,.35)).normalized()
 sun_opacity=0.0 if hostile else daylight
 $Receiver.material.set_shader_parameter("sun_strength",sun_opacity)
 host.get_node("WindowSpill").visible=not hostile
 host.get_node("WindowSpill").material.set_shader_parameter("strength",daylight*.55)
 host.get_node("WindowSpill").material.set_shader_parameter("skew",skew)
 host.get_node("Bedroom").material.set_shader_parameter("daylight",daylight/.4)
 var projection=Vector2(skew,daylight)
 if projection.distance_squared_to(_last_projection)>.000001:
  _last_projection=projection
  for caster in $Mask/Coordinates/Architecture.get_children():
   var footprint: PackedVector2Array=caster.get_meta("footprint")
   var center: Vector2=Vector2.ZERO
   for point in footprint:center+=point/float(footprint.size())
   var direction: Vector2=((center-Vector2(678,300)).normalized()+Vector2(skew,.35)).normalized()
   var points=footprint.duplicate()
   for point in footprint:points.append(point+direction*float(caster.get_meta("height"))*.55)
   caster.polygon=Geometry2D.convex_hull(points)
 $Mask/Coordinates/Architecture.visible=not hostile
 request_actor_shadow_redraw()
