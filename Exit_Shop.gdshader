shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if((UV.x < UV.y+1.25) && (UV.x > UV.y-1.25)){
		COLOR = vec4(1, 1, 1, 1);
	}
	else if(UV.x > 23.75-UV.y && UV.x < 26.25 - UV.y){
		COLOR = vec4(1, 1, 1, 1);
	}
	else{
		COLOR = vec4(1, 0, 0, 1);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
