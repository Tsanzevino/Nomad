shader_type spatial;
render_mode unshaded;

varying vec3 color;
varying float vertex_y;
varying float position;

uniform float min_height = 1;
uniform float max_height = 0;

void vertex() {
	// Called for every vertex the material is visible on.
	vertex_y = VERTEX.y;
	position = smoothstep(min_height, max_height, vertex_y);
	
	vec3 low = vec3(0.0,0.0,1.0);
	vec3 high = vec3(0.5,0.6,0.0);
	
	color = mix(low,high,position * position);
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
