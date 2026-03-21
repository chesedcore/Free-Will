shader_type spatial;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

// Water color
uniform vec4 out_color: source_color = vec4(0.0, 0.2, 1.0, 1.0);
// Amount of height for each triangle
uniform float amount: hint_range(0.2, 25.0, 0.1) = 0.8;
// The speed of the trangles height change
uniform float speed: hint_range(0.1, 25.0, 0.1) = 1;
// Beer factor (used to calculate how transparent the water is going to be) if equals to 0.0 then the alpha is going to be the out_color's alpha
uniform float beer_factor = 0.2;
uniform float metallic = 0.6;
uniform float specular = 0.5;
uniform float roughness = 0.2;

uniform sampler2D noise_texture_1;
uniform sampler2D noise_texture_2;

uniform float noise_1_strength = 50.0;
uniform float noise_2_strength = 100.0;

uniform float amplitude = 15.0;

float generateOffset(float x, float z, float val1, float val2, float time) {
	float radiansX = ((mod(x + z * x * val1, amount) / amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (time * speed) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;

	return amount * 0.5 * (sin(radiansZ) * cos(radiansX));
}

vec3 applyDistortion(vec3 vertex, float time) {
	float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
	float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);

	return vertex + vec3(xd, yd, zd);
}

void vertex() {
	// TODO: CARGO SHIPS NEED TO FOLLOW THE WAVES. COPY THIS MUHFUCKA TO DO IT AND SHIT
	float v1 = pow(2, texture(noise_texture_1, (UV * noise_1_strength + TIME * speed * 0.05) + TIME * speed * 0.01).r);
	float v2 = pow(2, texture(noise_texture_2, (UV * noise_2_strength + TIME * speed * 0.75) + TIME * speed).r);
	VERTEX.y = (v1 + v2) * amplitude;
}

void fragment() {
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	ALBEDO = out_color.rgb;
}