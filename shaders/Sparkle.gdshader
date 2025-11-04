shader_type canvas_item;

uniform bool is_positive = true;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(pow(UV.x-2.5, 2) + pow(UV.y-2.5, 2) <= 4.0){
		float range = sqrt(pow(UV.x-2.5, 2) + pow(UV.y-2.5, 2))/2.7;
		COLOR = vec4(1.0, 1.0, 1.0, texture(TEXTURE, UV).a);
	}else if(pow(UV.x-2.5, 2) + pow(UV.y-2.5, 2) <= 5.0){
		float range = pow(UV.x-2.5, 2) + pow(UV.y-2.5, 2);
		COLOR = vec4(1.0, 1.0, 5.0-range, texture(TEXTURE, UV).a);
		if(!is_positive){
			COLOR = vec4(1.0, 5.0-range, 5.0-range, texture(TEXTURE, UV).a);
		}
	}else if(pow(UV.x-2.5, 2) + pow(UV.y-2.5, 2) <= 6.0){
		COLOR = vec4(1, 1, 0, 1);
		if(!is_positive){
			COLOR = vec4(1, 0, 0, 1);
		}
	}else{
		COLOR = vec4(1, 1, 0, 0);
	}
	//if(pow(UV.x-2.5, 2) + pow(UV.y-2.5, 2) <= 6.0){
		//COLOR = vec4(1, 0, 0, 1);
	//}
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
