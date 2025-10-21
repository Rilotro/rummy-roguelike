shader_type canvas_item;

instance uniform float delay = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(pow(UV.x-10.0, 2) + pow(UV.y-10.0, 2) <= 100.0){
		COLOR.a = (sin(8.0*TIME - delay));
	}
	else{
		COLOR.a = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
