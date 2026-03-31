shader_type spatial;

render_mode cull_disabled, blend_add;

uniform vec4 color: source_color = vec4(1.0);
uniform float outer_radius = 0.35;
uniform float inner_radius = 0.275;
uniform vec2 uv_adjustment = vec2(0.,0.);
uniform float emission_strength = 50.;


float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}


void fragment(){
	
	float outer = circle(UV + uv_adjustment, outer_radius, 0.01);
	
	float fade_effect = sin(TIME) * 0.001;
	
	float inner = 1.0 - circle(UV + uv_adjustment, inner_radius, 0.1 - fade_effect );
	
	float alpha_value = COLOR.a;
	
	ALBEDO = color.rgb;
	EMISSION = color.rgb * (emission_strength - (outer + inner));
	ALPHA = max(alpha_value - (outer + inner), 0.);
	
}