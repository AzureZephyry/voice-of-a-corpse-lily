shader_type canvas_item;
render_mode unshaded;
uniform float sun_strength=.3;
void fragment(){vec4 mask=texture(TEXTURE,UV);float floor_mask=smoothstep(.40,.46,UV.y);COLOR=vec4(0.,0.,0.,max(mask.r*sun_strength,mask.g*.4)*floor_mask);}
