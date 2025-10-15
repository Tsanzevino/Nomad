shader_type spatial;

uniform sampler2D terrain_grass;
uniform sampler2D terrain_rock;
uniform float min_height = -5.0;
uniform float max_height = 5.0;
varying float vy;
uniform vec2 uvscale = vec2(5);

void vertex() {
	// Called for every vertex the material is visible on.
	vy = VERTEX.y;
}

void fragment() {
	vec3 grass = texture(terrain_grass,UV*uvscale).rgb;
	vec3 rock = texture(terrain_rock,UV*uvscale).rgb;
	
	//float weight = clamp((vy - min_height) / (max_height - min_height), 0.0, 1.0);
	float weight = smoothstep(min_height,max_height,vy);
	vec3 final_color = mix(grass,rock,weight);
	ALBEDO = final_color.rgb * final_color.rgb;
}



//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
