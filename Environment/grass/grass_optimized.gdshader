shader_type spatial;
render_mode cull_disabled, world_vertex_coords;

uniform sampler2D wind_noise_sampler;
uniform sampler2D gradient : source_color;

uniform float wind_speed = 1.0;
uniform float wind_strength = 2.0;

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i.x + i.y * 57.0);
    float b = hash(i.x + 1.0 + i.y * 57.0);
    float c = hash(i.x + (i.y + 1.0) * 57.0);
    float d = hash(i.x + 1.0 + (i.y + 1.0) * 57.0);

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void vertex(){
	NORMAL = vec3(0.0, 1.0, 0.0);
	vec2 noise_input = VERTEX.xz / 20.0 + 0.5 * TIME * wind_speed;

	float wind_value = noise(noise_input) * wind_strength;
	VERTEX.xz += wind_value * 0.1 * ( 1.0 - UV.y);
}

void fragment() {
	vec3 gradient_color = texture(gradient, vec2(UV.y, UV.x)).rgb;
	ALBEDO = gradient_color;
	NORMAL = NORMAL * (float(FRONT_FACING) * 2.0 - 1.0);
}
 