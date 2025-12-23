shader_type canvas_item;

// chromatic abberation shader
// taken from: https://mini.gmshaders.com/p/gm-shaders-mini-chromatic-aberration

uniform float aberr_x : hint_range(-1.0, 1.0) = 0.04;
uniform float aberr_y : hint_range(-1.0, 1.0) = 0.04;
uniform float sample_count = 8.0;

uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;

void fragment() {
	vec2 pixel_uv_size = 1.0 / vec2(textureSize(screen_texture, 0)); // for consistancy between resolutions
	vec2 offset = 100.0 * vec2(aberr_x * pixel_uv_size.x, aberr_y * pixel_uv_size.y);

	vec4 color_sum = vec4(0.0);
	vec4 weight_sum = vec4(0.0);

	for(float i = 0.0; i <= 1.0; i += 1.0/sample_count) {
		vec2 sample_coord = SCREEN_UV + ((i - 0.5) * offset);
		vec4 sample_color = texture(screen_texture, sample_coord);
		vec4 sample_weight = vec4(i, 1.0 - abs(i * 2.0 - 1.0), 1.0 - i, 0.5);
		
		color_sum += sample_color * sample_color * sample_weight;
		weight_sum += sample_weight;
	}

	COLOR = sqrt(color_sum / weight_sum);
}
