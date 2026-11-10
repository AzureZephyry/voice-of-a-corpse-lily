shader_type canvas_item;
uniform bool manifested=false;
uniform float daylight=.5;
uniform vec4 pane_color : source_color=vec4(.44,.55,.62,1.0);
varying vec4 tint;
void vertex(){tint=COLOR;}
void fragment(){
 vec4 art=texture(TEXTURE,UV);
 bool left_pane=UV.x>300.0/640.0 && UV.x<334.0/640.0 && UV.y>80.0/480.0 && UV.y<148.0/480.0;
 bool right_pane=UV.x>342.0/640.0 && UV.x<380.0/640.0 && UV.y>80.0/480.0 && UV.y<148.0/480.0;
 if(!manifested && (left_pane || right_pane)){
  float glass=clamp((.31-UV.y)*4.0,0.0,1.0);
  art=vec4(pane_color.rgb*(.9+.16*glass),1.0);
 }
 if(UV.x>.447 && UV.x<.547 && UV.y>.972)art.a=0.0;
 COLOR=art*tint;
}
