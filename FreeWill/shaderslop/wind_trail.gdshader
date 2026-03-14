shader_type spatial;
render_mode unshaded;

uniform lowp float edgefade : hint_range(0, 1) = 0.2;
uniform lowp float globalfade : hint_range(0, 1) = 0.5;
uniform lowp float max_alpha : hint_range(0, 1) = 1.;
uniform vec4 color_tint : source_color = vec4(1.);
uniform sampler2D noise;
//uniform sampler2D texture: source_color, filter_linear, repeat_disable;

void fragment () {
	float sinvresnel = pow(dot(normalize(NORMAL), normalize(VIEW)), (edgefade*25.0))*(1.0-globalfade);
	vec4 noise_value = texture(noise, UV);
	ALPHA = min(sinvresnel * noise_value.r, max_alpha);
	ALBEDO = color_tint.rgb;
}