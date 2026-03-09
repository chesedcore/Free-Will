shader_type canvas_item;

uniform sampler2D voronoi : repeat_enable;
uniform sampler2D perlin_noise : repeat_enable;

uniform float radius = 0.35;
uniform float intensity = 0.5;
uniform float smoothness = 0.25;
uniform float voronoi_speed = 0.25;
uniform float line_quantity = 4.0;

uniform vec4 color_offset: source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform vec2 screen_center = vec2(0.5, 0.5);


vec2 get_voronoi_angle_sample(vec2 uv){
	vec2 dist = normalize(uv - screen_center);
	float angle = atan(dist.y / dist.x);
	vec2 sample = vec2(radius * cos(angle), radius * sin(angle)) * line_quantity + TIME * voronoi_speed;
	return sample;
}

vec4 get_voronoi(vec2 uv) {
	vec2 sample = get_voronoi_angle_sample(uv);
	vec4 tex = texture(voronoi, sample + texture(perlin_noise, uv).r * 0.25);
	tex.a = texture(voronoi, sample).r * 2.0;
	return tex;
}

float get_perlin(vec2 uv){
	uv += TIME;
	return texture(perlin_noise, uv).r * 0.25 * intensity;
}

void fragment() {
	vec2 distance_vector = UV - vec2(0.5, 0.5);
	float distance_float = length(distance_vector);
	vec4 color;

	color = get_voronoi(UV);
	color.a *= get_perlin(UV);

	float alpha = smoothstep(radius, radius + smoothness, distance_float);
	color.a *= alpha;

	COLOR = color * color_offset;
}
