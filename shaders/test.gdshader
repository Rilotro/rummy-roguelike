shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(1, 1, 1, 0);
	float dist = sqrt(pow(UV.x-25.0, 2) + pow(UV.y-25.0, 2));
	if(dist <= 19.0 && dist >= 14.0){
		COLOR = vec4(0, 0, 1, 1);
	}
	
	if(dist <= 23.0 && dist >= 19.0){
		float angle = acos((UV.x-25.0)/(dist*sign(UV.y-25.0)));
		if(int((angle)*4.8 - 3.0*TIME) % 3 == 1){// - 3.0*TIME
			COLOR = vec4(0, 0, 1, 1);
		}
	}
}
