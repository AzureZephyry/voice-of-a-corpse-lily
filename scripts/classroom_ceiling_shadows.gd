extends Node
## Source-specific cached floor casts and explicit, approximate surface proxies.
## No collision edits, native Light2D pass, generated textures, or global shadow tint.
## Native Light2D/LightOccluder2D cannot distinguish floor and upright receivers in
## the flattened sprite, and would double-light this unshaded composition pass.
## These explicit proxy regions keep occlusion source-specific in that same pass.
const MASK_SHADER=preload("res://shaders/classroom_ceiling_mask.gdshader")
const SURFACE_SHADER=preload("res://shaders/classroom_surface_proxy.gdshader")
@onready var lighting=get_node("../ClassroomLighting")
@onready var sunlight=get_node("../ClassroomShadows")
var masks: Array[SubViewport]=[]
var surface: SubViewport
var _actors: Array[Dictionary]=[]
var _static: Array[Dictionary]=[]
var _last_sources: Array[Vector2]=[]
var _last_heights: Array[float]=[]
var redraw_count: int=0

func viewport(size: Vector2i, name_: String) -> SubViewport:
	var v=SubViewport.new()
	v.name=name_
	v.size=size
	v.transparent_bg=true
	v.world_2d=World2D.new()
	v.render_target_update_mode=SubViewport.UPDATE_ONCE
	add_child(v)
	var coordinates=Node2D.new()
	coordinates.name="Coordinates"
	coordinates.scale=Vector2(size)/Vector2(1280,960)
	coordinates.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	v.add_child(coordinates)
	return v

func surface_material(foot: float, kind: float, height: float=0.0, edge: float=-1.0) -> ShaderMaterial:
	var mat=ShaderMaterial.new()
	mat.shader=SURFACE_SHADER
	mat.set_shader_parameter("foot_y",foot)
	mat.set_shader_parameter("kind",kind)
	mat.set_shader_parameter("top_height",height)
	mat.set_shader_parameter("top_edge",edge)
	return mat

func _ready() -> void:
	process_priority=20
	surface=viewport(Vector2i(640,480),"SurfaceProxies")
	surface.get_child(0).y_sort_enabled=true
	# The actual rear wall joins the floor at y=328 in the supplied artwork.
	var wall=Polygon2D.new()
	wall.polygon=PackedVector2Array([Vector2(21,53),Vector2(1259,53),Vector2(1259,328),Vector2(21,328)])
	wall.z_index=-20
	wall.material=surface_material(328,5)
	wall.material.set_shader_parameter("textured",false)
	surface.get_child(0).add_child(wall)
	var furniture=get_node("../Classroom/Presentation/Normal/FurnitureDepth")
	for original in furniture.get_children():
		var copy=original.duplicate()
		surface.get_child(0).add_child(copy)
		for visual in copy.get_children():
			var kind=4.0 if str(original.name).begins_with("Row") else 1.0
			var height=0.0
			var edge=-1.0
			if visual.name==&"WritingArm":kind=2.0;height=30.0
			if str(original.name).begins_with("NorthCabinet"):height=58.0;edge=330.0
			if str(original.name).begins_with("WestCabinet"):kind=4.0
			if original.name==&"InstructorWorkstation":height=62.0;edge=715.0
			if original.name in [&"InstructorChair",&"FrontEquipment"]:kind=6.0
			if original.name==&"InstructorChair":height=42.0
			visual.material=surface_material(original.position.y,kind,height,edge)
			if original.name==&"InstructorChair":visual.material.set_shader_parameter("top_rect",Vector4(1119,584,57,52))
	for i in range(4):
		var v=viewport(Vector2i(320,240),"CeilingMask0"+str(i+1))
		masks.append(v)
		_last_sources.append(Vector2(INF,INF))
		_last_heights.append(-1.0)
		lighting.material.set_shader_parameter("ceiling_mask_"+str(i),v.get_texture())
		for caster in sunlight.casters.get_children():
			var poly=Polygon2D.new()
			poly.position=caster.position
			var mat=ShaderMaterial.new()
			mat.shader=MASK_SHADER
			mat.set_shader_parameter("foot",caster.position)
			mat.set_shader_parameter("half_footprint",-caster.get_meta("footprint")[0])
			poly.material=mat
			v.get_child(0).add_child(poly)
			_static.append({"lamp":i,"source":caster,"polygon":poly})
	lighting.material.set_shader_parameter("surface_proxy",surface.get_texture())
	lighting.material.set_shader_parameter("ceiling_masks_enabled",true)
	_bind_actors.call_deferred()

func _bind_actors() -> void:
	for actor in get_parent().find_children("ActorShadow2D","Node",true,false):
		# Manifested furniture reuses contact components, not animated actor proxies.
		if not actor._source is AnimatedSprite2D:
			continue
		var casts: Array[Sprite2D]=[]
		for i in range(4):
			var sprite=Sprite2D.new()
			var mat=ShaderMaterial.new()
			mat.shader=MASK_SHADER
			mat.set_shader_parameter("actor",true)
			sprite.material=mat
			masks[i].get_child(0).add_child(sprite)
			casts.append(sprite)
		var holder=Node2D.new()
		surface.get_child(0).add_child(holder)
		var proxy=Sprite2D.new()
		proxy.material=surface_material(0,3)
		holder.add_child(proxy)
		_actors.append({"actor":actor,"casts":casts,"surface":proxy,"holder":holder,"last":[]})

func _process(_delta: float) -> void:
	# Cached textures remain valid while all sources are off. No invisible mask work.
	if lighting.ceiling_lights.all(func(lamp):return lamp.current_intensity<0.0001):
		for v in masks:v.render_target_update_mode=SubViewport.UPDATE_DISABLED
		surface.render_target_update_mode=SubViewport.UPDATE_DISABLED
		return
	var changed=false
	var projection_changed=false
	for i in range(4):
		var lamp=lighting.ceiling_lights[i]
		if lamp.floor_position==_last_sources[i] and lamp.emitter_height==_last_heights[i]:continue
		_last_sources[i]=lamp.floor_position
		_last_heights[i]=lamp.emitter_height
		for entry in _static:
			if entry.lamp!=i:continue
			var source=entry.source
			var footprint: PackedVector2Array=source.get_meta("footprint")
			var points=footprint.duplicate()
			var height: float=float(source.get_meta("height"))*1.5
			for vertex in footprint:
				var displacement: Vector2=(source.position+vertex-lamp.floor_position)*height/maxf(100.0,lamp.emitter_height-height)
				points.append((vertex+displacement.limit_length(30)).round())
			entry.polygon.polygon=Geometry2D.convex_hull(points)
		changed=true
		projection_changed=true
	for entry in _actors.duplicate():
		var actor=entry.actor
		if not is_instance_valid(actor) or not is_instance_valid(actor._source):
			for cast in entry.casts:cast.queue_free()
			entry.holder.queue_free()
			_actors.erase(entry)
			changed=true
			continue
		var source: AnimatedSprite2D=actor._source
		var foot: Vector2=actor._feet.global_position
		var texture=source.sprite_frames.get_frame_texture(source.animation,source.frame)
		var state=[foot,source.global_transform,texture,source.flip_h,source.is_visible_in_tree()]
		if state==entry.last and not projection_changed:continue
		entry.last=state
		var proxy: Sprite2D=entry.surface
		entry.holder.position=foot
		proxy.transform=source.global_transform
		proxy.position-=foot
		proxy.texture=texture
		proxy.centered=source.centered
		proxy.offset=source.offset
		proxy.flip_h=source.flip_h
		proxy.visible=source.is_visible_in_tree()
		proxy.material.set_shader_parameter("foot_y",foot.y)
		proxy.material.set_shader_parameter("foot_x",foot.x)
		for i in range(4):
			var lamp=lighting.ceiling_lights[i]
			var cast: Sprite2D=entry.casts[i]
			var slope: Vector2=((foot-lamp.floor_position)/maxf(100.0,lamp.emitter_height-80.0)*0.85).limit_length(0.32)
			var visual: Transform2D=source.global_transform
			visual.origin-=foot
			cast.transform=Transform2D(Vector2.RIGHT,Vector2(-slope.x,0.02-slope.y),foot)*visual
			cast.texture=texture
			cast.centered=source.centered
			cast.offset=source.offset
			cast.flip_h=source.flip_h
			cast.visible=source.is_visible_in_tree()
			cast.material.set_shader_parameter("foot",foot)
		changed=true
	if changed:
		for v in masks:v.render_target_update_mode=SubViewport.UPDATE_ONCE
		surface.render_target_update_mode=SubViewport.UPDATE_ONCE
		redraw_count+=1
