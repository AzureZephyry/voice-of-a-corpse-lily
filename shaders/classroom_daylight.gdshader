shader_type canvas_item;
render_mode unshaded, blend_disabled;
uniform sampler2D world_image : hint_screen_texture, filter_nearest, repeat_disable;
#include "res://shaders/screen_actor_protection.gdshaderinc"
uniform bool manifested_mode = false;
uniform float manifested_exposure = 0.36;
uniform float manifested_highlights = 0.12;
uniform float manifested_contact_strength = 0.16;
uniform vec4 manifested_tint : source_color = vec4(0.96, 0.98, 1.0, 1.0);
// Irradiance coefficients multiply the original artwork once, after source addition.
uniform vec4 ambient_color : source_color = vec4(0.40,0.40,0.40,1.0);
uniform vec4 window_color : source_color = vec4(1.0);
uniform vec4 pane_color : source_color = vec4(0.48,0.62,0.70,1.0);
uniform float window_strength = 0.0;
uniform vec2 window_fill_radius = vec2(420.0,580.0);
uniform float window_fill_strength = 0.70;
uniform float window_direct_strength = 0.38;
uniform vec4 ceiling_sources[4]; // xy native artwork anchor, z actual intensity, w falloff
uniform vec4 ceiling_colors[4] : source_color;
uniform vec2 ceiling_reach[4];
uniform float ceiling_heights[4];
uniform bool ceiling_masks_enabled=false;
uniform sampler2D ceiling_mask_0 : filter_nearest, repeat_disable;
uniform sampler2D ceiling_mask_1 : filter_nearest, repeat_disable;
uniform sampler2D ceiling_mask_2 : filter_nearest, repeat_disable;
uniform sampler2D ceiling_mask_3 : filter_nearest, repeat_disable;
uniform sampler2D surface_proxy : filter_nearest, repeat_disable;
uniform vec4 interaction_marker_rect=vec4(0.0);
uniform vec2 viewport_size = vec2(1280.0,960.0);
// Actual window sills in Wayne's native 1280x960 composition.
uniform vec2 west_sill = vec2(430.0,274.0);
uniform vec2 east_sill = vec2(850.0,274.0);
uniform vec2 sun_direction = vec2(-0.287,0.958);
uniform float light_reach = 510.0;
uniform float sun_opacity = 0.16;
uniform bool shadows_enabled = false;
uniform sampler2D shadow_mask : filter_nearest, repeat_disable;
float aperture(float x, float left, float right, float softness) {
    return smoothstep(left-softness,left+softness,x)*(1.0-smoothstep(right-softness,right+softness,x));
}
float daylight(vec2 p, vec2 sill, vec4 openings) {
    float depth = max(p.y-sill.y,0.0);
    float travel = depth / max(sun_direction.y,0.6);
    float entry_x = p.x - sun_direction.x * travel;
    // Project the known curtain/frame gaps, progressively diffusing with distance.
    float softness = 8.0 + travel * 0.08;
    float transmission = max(aperture(entry_x,openings.x,openings.y,softness),aperture(entry_x,openings.z,openings.w,softness));
    float falloff = exp2(-2.0*travel/max(light_reach,1.0))*(1.0-smoothstep(light_reach*0.45,light_reach,travel));
    return transmission * falloff * smoothstep(sill.y-4.0,sill.y+12.0,p.y);
}
bool floor_pixel(vec3 c) {
    // The two actual tile/grid colors in Wayne's artwork; furniture/actors excluded.
    vec3 pixel = c*255.0;
    return all(lessThan(abs(pixel-vec3(164.0,178.0,179.0)),vec3(0.6))) || all(lessThan(abs(pixel-vec3(132.0,142.0,143.0)),vec3(0.6)));
}
float window_fill(vec2 p, vec2 sill) {
    // Soft skylight/bounce approximation localized to each existing pane center.
    // This is not a second world-wide exposure or a claimed physical bounce solver.
    vec2 delta = (p-(sill-vec2(0.0,75.0)))/max(window_fill_radius,vec2(1.0));
    float distance = length(delta);
    return exp2(-1.7*distance)*(1.0-smoothstep(1.4,2.0,distance));
}
vec3 ambient_irradiance() {
    return ambient_color.rgb;
}
vec3 window_irradiance(vec2 p, bool floor_receiver, float cast_coverage) {
    float direct = max(daylight(p,west_sill,vec4(402.0,497.0,362.0,380.0)),daylight(p,east_sill,vec4(784.0,880.0,902.0,918.0)));
    float west_fill = window_fill(p,west_sill);
    float east_fill = window_fill(p,east_sill);
    // Bounded overlap keeps two nearby windows from doubling diffuse illumination.
    float diffuse = 1.0-(1.0-west_fill)*(1.0-east_fill);
    float pane_energy = clamp(dot(pane_color.rgb,vec3(0.2126,0.7152,0.0722))/0.6,0.0,1.0);
    float occlusion = clamp(cast_coverage/0.65,0.0,1.0);
    // The existing sun mask attenuates window sunlight only. It cannot shadow
    // neutral ambient or Stage 2 fixtures, whose sources will need their own rules.
    float sun_visibility = 1.0-occlusion*0.85*clamp(sun_opacity/0.16,0.0,1.0);
    float floor_direct = floor_receiver ? direct*sun_visibility*window_direct_strength : 0.0;
    // Upright flattened art receives soft fill, never a painted white beam stripe.
    float surface_fill = diffuse*window_fill_strength*(floor_receiver ? 1.0 : 0.85);
    return window_color.rgb*window_strength*pane_energy*(surface_fill+floor_direct);
}
vec3 ceiling_irradiance(vec2 p, bool floor_receiver) {
    if (ceiling_sources[0].z+ceiling_sources[1].z+ceiling_sources[2].z+ceiling_sources[3].z<0.0001) { return vec3(0.0); }
    vec3 sum = vec3(0.0);
    vec2 ground=p;
    float height=0.0;
    int receiver_kind=0;
    vec3 normal=vec3(0.0,0.0,1.0);
    if (!floor_receiver && ceiling_masks_enabled) {
        vec4 proxy=texture(surface_proxy,p/vec2(1280.0,960.0));
        int kind=int(round(proxy.a*8.0));
        receiver_kind=kind;
        if (kind>0) {
            ground=proxy.rg*vec2(1280.0,960.0);
            height=proxy.b*200.0;
            if (kind==1 || kind==5) { normal=normalize(vec3(0.0,1.0,0.15)); }
            if (kind==4) { normal=normalize(vec3(1.0,0.0,0.15)); }
            if (kind==6) { normal=normalize(vec3(-1.0,0.0,0.15)); }
            // Deliberate capsule proxy, not normals allegedly present in the sprite.
            if (kind==3) { normal=normalize(vec3(clamp((p.x-ground.x)/28.0,-0.7,0.7),-0.10,0.70)); }
        }
    }
    for (int i=0;i<4;i++) {
        if (ceiling_sources[i].z<0.0001) { continue; }
        vec2 toward=ceiling_sources[i].xy-ground;
        vec2 delta=-toward/max(ceiling_reach[i],vec2(1.0));
        float distance2=dot(delta,delta);
        float attenuation=1.0/(1.0+ceiling_sources[i].w*distance2+0.5*distance2*distance2);
        attenuation*=1.0-smoothstep(4.0,9.0,distance2);
        // Lift a surface's sample toward its source to approximate elevated receivers.
        vec2 sample_point=ground+toward*height/max(ceiling_heights[i],1.0);
        vec2 uv=clamp(sample_point/vec2(1280.0,960.0),vec2(0.001),vec2(0.999));
        float coverage=0.0;
        if (ceiling_masks_enabled) {
            if (i==0) { coverage=texture(ceiling_mask_0,uv).r; }
            if (i==1) { coverage=texture(ceiling_mask_1,uv).r; }
            if (i==2) { coverage=texture(ceiling_mask_2,uv).r; }
            if (i==3) { coverage=texture(ceiling_mask_3,uv).r; }
        }
        // Ground masks cannot occlude a receiver above these low furnishings.
        // Fade their influence rather than projecting chair stamps up the wall.
        coverage*=1.0-smoothstep(30.0,90.0,height);
        float incidence=max(dot(normal,normalize(vec3(toward,max(20.0,ceiling_heights[i]-height)))),0.0);
        // The rear wall has no authored height/normal layers. Give it local
        // secondary fill only; never project floor-shadow stamps onto that wall.
        if (receiver_kind==5) { coverage=0.0; incidence*=0.18; }
        float visibility=1.0-clamp(coverage,0.0,1.0)*0.85;
        sum+=ceiling_colors[i].rgb*ceiling_sources[i].z*attenuation*incidence*visibility;
    }
    // Diminishing overlap keeps neighboring sources broad without washing out art.
    vec3 energy=sum/0.70;
    return 0.60*(vec3(1.0)-1.0/(vec3(1.0)+energy+0.5*energy*energy));
}
void fragment() {
    if (manifested_mode) {
        vec2 pixel = SCREEN_UV / SCREEN_PIXEL_SIZE;
        vec4 source = texture(world_image, SCREEN_UV);
        if (protected_actor(pixel) > 0.5 && visible_actor_color(pixel, source.rgb)) {
            COLOR = source;
        } else {
            float luminance = dot(source.rgb, vec3(0.2126, 0.7152, 0.0722));
            float highlight = smoothstep(0.60, 1.0, luminance);
            // Tone existing pixels once; keep the painted grain sharp, not brighter
            // invented lamps or sunlight through these deliberately black windows.
            vec3 toned = mix(source.rgb, vec3(luminance), 0.12);
            float exposure = manifested_exposure + manifested_highlights * highlight;
            // Measured manifested pane interiors: preserve the EXISTING eye whites.
            // This neither replaces pane colors nor creates scenery/eye glow.
            bool pane = pixel.y >= 130.0 && pixel.y < 268.0 &&
                ((pixel.x >= 402.0 && pixel.x < 497.0) || (pixel.x >= 784.0 && pixel.x < 880.0));
            if (pane) exposure += 0.18 * highlight;
            float contact = texture(shadow_mask, SCREEN_UV).g;
            // Already-black roots/furniture retain their baked darkness. The shared
            // mask contains only grounding contacts here, never Normal cast shapes.
            float ground = 1.0 - contact * manifested_contact_strength * smoothstep(0.08, 0.25, luminance);
            COLOR = vec4(toned * manifested_tint.rgb * exposure * ground, source.a);
        }
    } else {
    vec2 p = floor(SCREEN_UV * viewport_size);
    vec3 original = texture(world_image,SCREEN_UV).rgb;
    bool floor_receiver = floor_pixel(original);
    vec2 mask = vec2(0.0);
    if (shadows_enabled) {
        mask = texture(shadow_mask,SCREEN_UV).rg;
        // Feather coverage by one mask texel, never filter the pixel artwork.
        vec2 side = vec2(sun_direction.y,-sun_direction.x)*2.0/viewport_size;
        mask.r = mask.r*0.6 + texture(shadow_mask,SCREEN_UV-side).r*0.2 + texture(shadow_mask,SCREEN_UV+side).r*0.2;
    }
    vec3 illumination = ambient_irradiance()
                      + window_irradiance(p,floor_receiver,mask.r)
                      + ceiling_irradiance(p,floor_receiver);
    illumination = min(vec3(1.04),illumination);
    if (shadows_enabled && floor_receiver) {
        // Contact occlusion grounds objects under any source, including at night.
        float contact = clamp(mask.g,0.0,1.0)*0.18;
        illumination *= 1.0-contact;
    }
    // Four measured aperture bounds, with exclusive upper edges. The curtain-cut
    // slits need the original black-pixel test; handles and frame pixels stay intact.
    bool west = (p.x>=402.0 && p.x<497.0) || (p.x>=362.0 && p.x<380.0);
    bool east = (p.x>=784.0 && p.x<880.0) || (p.x>=902.0 && p.x<918.0);
    bool pane = (west || east) && p.y>=130.0 && p.y<268.0 && max(original.r,max(original.g,original.b))<0.001;
    // Pane color is already the coordinated exterior illumination, not a second tint.
    float pane_depth = clamp((p.y-130.0)/138.0,0.0,1.0);
    COLOR = vec4(pane ? pane_color.rgb*mix(1.03,0.90,pane_depth) : original * illumination,1.0);
    bool marker=all(greaterThanEqual(p,interaction_marker_rect.xy)) && all(lessThan(p,interaction_marker_rect.xy+interaction_marker_rect.zw));
    bool marker_ink=all(lessThan(abs(original-vec3(0.95,0.87,0.65)),vec3(0.005))) || all(lessThan(abs(original-vec3(0.16,0.21,0.23)),vec3(0.005)));
    if (marker && marker_ink) { COLOR.rgb=original; }
    }
}
