shader_type canvas_item;

instance uniform bool is_rainbow = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// texture(TEXTURE, UV).a
	if(is_rainbow){
		float cycles = 36.0;
		float color_step = 1.0/(cycles*6.0);
		for(float i = (cycles-1.0)/cycles; i >= 0.0; i -= 1.0/cycles){
			if(UV.x >= i){
				if(UV.x < i+color_step){
					float G = (UV.x-i)/color_step;
					COLOR = vec4(1.0, G, 0.0, texture(TEXTURE, UV).a);
				}
				else if(UV.x < i+2.0*color_step){
					float R = 1.0-(UV.x-i-color_step)/color_step;
					COLOR = vec4(R, 1.0, 0.0, texture(TEXTURE, UV).a);
				}
				else if(UV.x < i+3.0*color_step){
					float B = (UV.x-i-2.0*color_step)/color_step;
					COLOR = vec4(0.0, 1.0, B, texture(TEXTURE, UV).a);
				}
				else if(UV.x < i+4.0*color_step){
					float G = 1.0-(UV.x-i-3.0*color_step)/color_step;
					COLOR = vec4(0.0, G, 1.0, texture(TEXTURE, UV).a);
				}
				else if(UV.x < i+5.0*color_step){
					float R = (UV.x-i-4.0*color_step)/color_step;
					COLOR = vec4(R, 0.0, 1.0, texture(TEXTURE, UV).a);
				}
				else if(UV.x < i+6.0*color_step){
					float B = 1.0-(UV.x-i-5.0*color_step)/color_step;
					COLOR = vec4(1.0, 0.0, B, texture(TEXTURE, UV).a);
				}
			}
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
