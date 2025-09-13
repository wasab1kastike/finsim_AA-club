shader_type canvas_item;

uniform float line_thickness : hint_range(0.0, 10.0) = 1.0;
uniform float line_alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec2 offset = line_thickness * TEXTURE_PIXEL_SIZE;
    float outline = 0.0;
    outline += texture(TEXTURE, UV + vec2(offset.x, 0.0)).a;
    outline += texture(TEXTURE, UV + vec2(-offset.x, 0.0)).a;
    outline += texture(TEXTURE, UV + vec2(0.0, offset.y)).a;
    outline += texture(TEXTURE, UV + vec2(0.0, -offset.y)).a;
    outline = clamp(outline, 0.0, 1.0);
    float mask = outline * (1.0 - tex.a);
    COLOR = tex + vec4(0.0, 0.0, 0.0, line_alpha * mask);
}
