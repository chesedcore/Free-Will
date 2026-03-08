shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back;

void fragment() {
    ALBEDO = vec3(0.0);
    ALPHA = 0.0;
}

void light() {
    // Only show the shadow part of lighting
    float shadow = ATTENUATION;
    DIFFUSE_LIGHT = vec3(1.0 - shadow);
}