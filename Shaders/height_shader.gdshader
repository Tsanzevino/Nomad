shader_type spatial;

varying vec3 color;
varying float vertex_y;

uniform float min_height = 0;
uniform float max_height = 1;

float inverseLerp(float a, float b, float value) {
	float val = (value - a) / (b - a);
	return clamp(0.01, 1.0, val);
}
void vertex() {
	// Called for every vertex the material is visible on.
	vertex_y = VERTEX.y;
	float position = inverseLerp(min_height, max_height, vertex_y);
	color = vec3(0, position, 0.1);
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
