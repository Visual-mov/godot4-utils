shader_type canvas_item;

uniform float divisions = 200.0;

uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;

void fragment() {
    vec2 st = (vec2(ivec2(SCREEN_UV * divisions))+0.5) / divisions;
    vec4 tex_col = textureLod(screen_texture, st, 0);
    COLOR = tex_col;
}
