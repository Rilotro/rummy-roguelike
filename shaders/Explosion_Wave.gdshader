shader_type canvas_item;

uniform float range = 0.0;
//uniform vec4 my_modulate: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(sqrt(pow(UV.x-20.0, 2) + pow(UV.y-20.0, 2)) <= range + 5.0 && sqrt(pow(UV.x-20.0, 2) + pow(UV.y-20.0, 2)) >= range){
		//COLOR = vec4(0, 1, 0, COLOR.a);
	}else{
		COLOR = vec4(0, 1, 0, 0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
