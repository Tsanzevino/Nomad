shader_type spatial;

varying vec3 color;

void vertex() {
	// Called for every vertex the material is visible on.
	color = COLOR.rgb;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
