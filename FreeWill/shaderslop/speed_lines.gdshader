shader_type canvas_item;

uniform sampler2D voronoi : repeat_enable;
uniform sampler2D perlin_noise : repeat_enable;
uniform float radius = 0.35;
uniform float radius_intensity = 0.0;
uniform float intensity = 0.5;
uniform float smoothness = 0.25;
uniform float voronoi_speed = 0.25;
uniform float line_quantity = 4.0;
uniform vec4 color_offset: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 screen_center = vec2(0.5, 0.5);
uniform float flow_speed = 0.5;
uniform vec2 movement_direction = vec2(0.0, 1.0); //script owns this stat
uniform float radial_blend = 1.0;
//            ^^^^^^^^^^^^^0 is directional flow, 1 is radial flow

vec2 get_voronoi_angle_sample(vec2 uv){
	vec2 dist = normalize(uv - screen_center);
	float angle = atan(dist.y, dist.x);
	                  //^^^^^^ we need atan2 behaviour here, so from -PI<->PI
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
	vec2 centered_uv = uv - screen_center;

	//radial direction from center -> out using dist normalisation (fuck US spelling)
	vec2 radial_dir = normalize(centered_uv);

	//this is the part that eases between bidir and radial flow
	vec2 direction = mix(movement_direction, radial_dir, radial_blend);
	if (length(direction) > 0.01) {
		direction = normalize(direction);
	}

	vec2 flowing_uv = uv - direction * TIME * flow_speed;

	return texture(perlin_noise, flowing_uv).r * 0.25 * intensity;
}

void fragment() {
	vec2 distance_vector = UV - screen_center;
	float distance_float = length(distance_vector);

	vec4 color;
	color = get_voronoi(UV);
	color.a *= get_perlin(UV);

	float alpha = smoothstep(radius - radius_intensity, radius + smoothness, distance_float);
	color.a *= alpha;

	COLOR = color * color_offset;
}