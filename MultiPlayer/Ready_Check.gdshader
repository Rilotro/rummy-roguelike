shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(0, 1, 0, 1);
	if(UV.x >= UV.y-0.55 && UV.x <= UV.y-0.45){
		COLOR = vec4(1, 1, 1, 1);
	}
	if(1.0-2.0*UV.x >= UV.y-1.08 && 1.0-2.0*UV.x <= UV.y-0.92){
		COLOR = vec4(1, 1, 1, 1);
	}
	//if(UV.x >= UV.y - 0.3 && UV.x <= UV.y + 0.7){
		//COLOR = vec4(1, 1, 1, 1);
	//}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
