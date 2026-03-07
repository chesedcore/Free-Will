shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 0.2) = 0.04;

void fragment()
{
    vec2 uv = SCREEN_UV;
    vec2 centered = uv * 2.0 - 1.0;

    float r2 = dot(centered, centered);
    vec2 warped = centered * (1.0 + strength * r2);

    vec2 final_uv = warped * 0.5 + 0.5;
    COLOR = texture(SCREEN_TEXTURE, final_uv);
}
