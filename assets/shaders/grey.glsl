
//@renderpasses 0

uniform sampler2D m_SourceTexture;
uniform vec2 m_SourceTextureSize;
uniform vec2 m_SourceTextureScale;

uniform int m_GreyMode;

varying vec2 v_TexCoord0;

//@vertex

attribute vec2 a_Position;	//0...1 (1=viewport size)

void main(){

	v_TexCoord0 = a_Position * m_SourceTextureScale;

	gl_Position=vec4( a_Position * 2.0 - 1.0,-1.0,1.0 );
	
}

//@fragment

void main(){

	vec3 pixels = texture2D (m_SourceTexture, v_TexCoord0).rgb;

	float rgb;
	
	switch (m_GreyMode)
	{
		case 0:
			
			// Default RGB
			
			break;	// Disabled, jumps through to case 3
					// (as if going through all cases and
					// simply ending up there)
			
					// Enabled, always skips the rest, even
					// though m_Mode is set to higher value!

		case 1:
		
			// Lightness
			
			rgb = (max(max(pixels.r, pixels.g), pixels.b) + min(min(pixels.r, pixels.g), pixels.b)) / 2.0;
			
			pixels.r = rgb;
			pixels.g = rgb;
			pixels.b = rgb;
			
			break;
			
		case 2:
		
			// Average
			
			rgb = (pixels.r + pixels.g + pixels.b) / 3.0;
			
			pixels.r = rgb;
			pixels.g = rgb;
			pixels.b = rgb;

			break;
			
		case 3:
		
			// Luminosity
			
			rgb = (pixels.r * 0.21) + (pixels.g * 0.72) + (pixels.b * 0.07);
			
			pixels.r = rgb;
			pixels.g = rgb;
			pixels.b = rgb;

//			pixels = vec3 (1.0, 0.0, 0.0); // *** TEST - RED pixelsS ***
	}
	
	gl_FragColor = vec4 (pixels, 1.0);
	
}
