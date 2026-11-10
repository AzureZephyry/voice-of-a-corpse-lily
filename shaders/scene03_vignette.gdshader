shader_type canvas_item;
render_mode unshaded;
uniform float strength=0.0;
void fragment(){
 vec2 p=UV*2.0-1.0;
 float edge=smoothstep(0.4,1.15,length(p*vec2(0.85,1.0)));
 COLOR=vec4(0.035,0.025,0.045,edge*strength);
}
