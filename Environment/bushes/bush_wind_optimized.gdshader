shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_sampler : source_color;
uniform sampler2D orm_sampler;
uniform sampler2D normal_sampler;

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

void vertex() {
	vec2 noise_input = (UV.y) + VERTEX.y + NODE_POSITION_WORLD.xz + vec2(0.0, (TIME * wind_speed));
	float wind_value = noise(noise_input) * wind_strength;
	VERTEX.xz += (wind_value) * 0.05 * UV.y;
}

void fragment() {
	vec4 albedo = texture(albedo_sampler, UV);
	vec3 orm = texture(orm_sampler, UV).rgb;
	vec3 normal_map = texture(normal_sampler, UV).rgb;

	ALBEDO = albedo.rgb * orm.r;
	ROUGHNESS = orm.g;
	NORMAL_MAP = normal_map;
	ALPHA = albedo.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
