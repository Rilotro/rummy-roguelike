shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if((UV.x < UV.y+0.05) && (UV.x > UV.y-0.05)){
		COLOR = vec4(1, 1, 1, 1);
	}
	else if(UV.x > 0.95-UV.y && UV.x < 1.05 - UV.y){
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
