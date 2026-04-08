shader_type canvas_item;

uniform float loadingTime;
//uniform bool loading = true;

void vertex() {
	// Called for every vertex the material is visible on.
}

//uniform float angle = 0.0;

void fragment() {
	float origAlpha = COLOR.a;
	int rotations = int(floor(3.0*(loadingTime)/(2.0*PI)));//-startTime
	if(rotations < 1){
		COLOR.a = 0.0;

		float angle = atan(UV.y-155.5, UV.x-42.5);
		if(angle < 0.0){
			angle = 2.0*PI + angle;
		}

		if(angle <= 3.0*(loadingTime) - 2.0*PI*float(rotations)){//TIME-startTime
			COLOR.a = origAlpha;
		}
	}

	if((UV.x < 80.0 && UV.x > 5.0) && (UV.y < 305.0 && UV.y > 5.0)){
		COLOR.a = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
