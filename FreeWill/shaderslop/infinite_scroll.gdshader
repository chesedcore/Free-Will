shader_type canvas_item;

uniform vec2 direction = vec2(1.0, 0.0);
uniform float speed = 0.2;

void fragment() {
	vec2 uv = UV;
	uv += direction * TIME * speed;
	uv = fract(uv);
	COLOR = texture(TEXTURE, uv);
}