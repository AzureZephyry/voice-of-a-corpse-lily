extends RefCounted
## Bind original atlas alpha; never copy/recolor/rebuild an actor texture.
static func apply(target: ShaderMaterial, actor: AnimatedSprite2D) -> Texture2D:
	var texture: Texture2D = actor.sprite_frames.get_frame_texture(actor.animation, actor.frame)
	var size: Vector2 = texture.get_size()
	if texture is AtlasTexture:
		target.set_shader_parameter("actor_atlas", texture.atlas)
		var atlas_size: Vector2 = texture.atlas.get_size()
		target.set_shader_parameter("actor_region", Vector4(texture.region.position.x / atlas_size.x, texture.region.position.y / atlas_size.y, texture.region.size.x / atlas_size.x, texture.region.size.y / atlas_size.y))
	else:
		target.set_shader_parameter("actor_atlas", texture)
		target.set_shader_parameter("actor_region", Vector4(0, 0, 1, 1))
	var origin: Vector2 = actor.offset - (size * 0.5 if actor.centered else Vector2.ZERO)
	target.set_shader_parameter("actor_rect", Vector4(origin.x, origin.y, size.x, size.y))
	var inverse: Transform2D = actor.get_global_transform_with_canvas().affine_inverse()
	target.set_shader_parameter("actor_inverse_x", Vector3(inverse.x.x, inverse.y.x, inverse.origin.x))
	target.set_shader_parameter("actor_inverse_y", Vector3(inverse.x.y, inverse.y.y, inverse.origin.y))
	target.set_shader_parameter("actor_flip", Vector2(float(actor.flip_h), float(actor.flip_v)))
	return texture
