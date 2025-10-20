shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//if(UV.x >= 0.996 || UV.x <= 0.004 || UV.y >= 0.99 || UV.y <= 0.02){
		//COLOR = vec4(0, 0, 0, 1);
	//}
	//else{
	COLOR = vec4(0.1 + 0.3*sin(PI*UV.y), 0.1 + 0.3*sin(PI*UV.y), 0.8, 1);
	//}
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
