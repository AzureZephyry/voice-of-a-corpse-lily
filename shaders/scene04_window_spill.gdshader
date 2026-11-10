shader_type canvas_item;
render_mode unshaded;
uniform float strength=.17;
uniform float skew=0.0;
uniform vec4 light_color : source_color=vec4(.83,.82,.73,1.0);
void fragment(){
 vec2 p=UV*vec2(1280.0,960.0);
 float t=clamp((p.y-425.0)/430.0,0.0,1.0);
 float spread=1.0+t*.55;
 float center=678.0+skew*t*150.0;
 float panes=0.0;
 for(int i=0;i<2;i++){
  float x=center+(i==0 ? -44.0:44.0)*spread;
  panes=max(panes,1.0-smoothstep(29.0*spread,39.0*spread,abs(p.x-x)));
 }
 float floor_light=panes*smoothstep(413.0,448.0,p.y)*(1.0-smoothstep(690.0,860.0,p.y));
 float wall_lift=max(0.0,1.0-length((p-vec2(678.0,328.0))/vec2(110.0,120.0)))*.25;
 COLOR=vec4(light_color.rgb,(floor_light+wall_lift)*strength);
}
