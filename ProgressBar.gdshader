shader_type canvas_item;

instance uniform float progress_alpha = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float alpha = 0.0;
	if(UV.x < progress_alpha){
		alpha = 1.0;
	}
	//COLOR = vec4(UV.y, 1.0 - UV.y, 0, alpha);
	//COLOR = vec4(sin(PI/2.0*UV.y), cos(PI/2.0*UV.y), 0, alpha);
	//float acc_Y = 1.0-UV.y;
	float cycles = 4.0;
	float color_step = 1.0/(cycles*6.0);
	for(float i = (cycles-1.0)/cycles; i >= 0.0; i -= 1.0/cycles){
		if(UV.x >= i){
			if(UV.x < i+color_step){
				float G = (UV.x-i)/color_step;
				COLOR = vec4(1.0, G, 0.0, alpha);
			}
			else if(UV.x < i+2.0*color_step){
				float R = 1.0-(UV.x-i-color_step)/color_step;
				COLOR = vec4(R, 1.0, 0.0, alpha);
			}
			else if(UV.x < i+3.0*color_step){
				float B = (UV.x-i-2.0*color_step)/color_step;
				COLOR = vec4(0.0, 1.0, B, alpha);
			}
			else if(UV.x < i+4.0*color_step){
				float G = 1.0-(UV.x-i-3.0*color_step)/color_step;
				COLOR = vec4(0.0, G, 1.0, alpha);
			}
			else if(UV.x < i+5.0*color_step){
				float R = (UV.x-i-4.0*color_step)/color_step;
				COLOR = vec4(R, 0.0, 1.0, alpha);
			}
			else if(UV.x < i+6.0*color_step){
				float B = 1.0-(UV.x-i-5.0*color_step)/color_step;
				COLOR = vec4(1.0, 0.0, B, alpha);
			}
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
