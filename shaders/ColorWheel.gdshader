shader_type canvas_item;

uniform float canvasSize = 50.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(sqrt(pow((UV.x-canvasSize/2.0), 2.0) + pow((UV.y-canvasSize/2.0), 2.0)) > canvasSize/2.0){
		COLOR.a = 0.0;
	}
	
	if(sqrt(pow((UV.x-canvasSize/2.0), 2.0) + pow((UV.y-canvasSize/2.0), 2.0)) <= canvasSize/20.0){
		COLOR = vec4(0, 0, 0, 1);
	}
	
	if(UV.x >= canvasSize/2.0 - 2.0 && UV.x <= canvasSize/2.0 + 2.0){
		COLOR = vec4(0, 0, 0, COLOR.a);
	}
	
	if(UV.y >= canvasSize/2.0 - 2.0 && UV.y <= canvasSize/2.0 + 2.0){
		COLOR = vec4(0, 0, 0, COLOR.a);
	}
	
	if(UV.x >= UV.y - 3.0 && UV.x <= UV.y + 3.0){
		COLOR = vec4(0, 0, 0, COLOR.a);
	}
	
	if(UV.x >= canvasSize-UV.y - 3.0 && UV.x <= canvasSize-UV.y + 3.0){
		COLOR = vec4(0, 0, 0, COLOR.a);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
