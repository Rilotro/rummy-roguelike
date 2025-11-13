shader_type canvas_item;

instance uniform vec4 color: source_color = vec4(1.0);
uniform float direction: hint_range(-1.0, 1.0, 1.0) = -1.0;
uniform float frequency: hint_range(0.1, 30.0, 0.1) = 40.0; // the number of dotted lines
instance uniform float speed: hint_range(0.0, 20, 0.5) = 0.0;     // rotation speed
uniform float radius: hint_range(0.01, 100.0, 0.01) = 50.0;
uniform float line_thickness: hint_range(0.0, 0.5, 0.01) = 0.03;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 circle_outline;
	vec2 pos = UV - vec2(19.5, 30.0);
	float circle = step(length(pos), radius);
	float angle = atan(pos.y, pos.x);

	float wave = 0.5 * sin(direction * frequency * angle + TIME * speed) + 0.5;

	circle *= step(0.5, wave);
	circle_outline = vec4(color.rgb, circle * color.a);

	float rect_alpha = 1.0 - step(abs(pos.x), (17.5-line_thickness)) * step(abs(pos.y), (28.0-line_thickness));
	COLOR =  circle_outline * vec4(1.0, 1.0, 1.0, rect_alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
