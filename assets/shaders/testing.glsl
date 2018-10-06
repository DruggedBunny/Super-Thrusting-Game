
//@renderpasses 0

uniform sampler2D m_SourceTexture;
uniform vec2 m_SourceTextureSize;
uniform vec2 m_SourceTextureScale;

varying vec2 v_TexCoord0;

//@vertex

attribute vec2 a_Position;	//0...1 (1=viewport size)

void main(){

	v_TexCoord0 = a_Position * m_SourceTextureScale;

	gl_Position=vec4( a_Position * 2.0 - 1.0,-1.0,1.0 );
}

//@fragment

void main(){

	vec3 black = vec3(0.0, 0.0, 0.0);
	vec3 white = vec3(1.0, 1.0, 1.0);
	
	vec3 pixels = texture2D (m_SourceTexture, v_TexCoord0).rgb;

	//	pixels.r = (float (true));				' Ruined film, red cast
	//	pixels.r = (float (pixels.r > 0.5));	' Weird glitch
	
	//	B & W mask...
	
	//	pixels.r = (float (pixels.r > 0.1));
	//	pixels.g = pixels.r;
	//	pixels.b = pixels.r;
	
	//	Interesting blend...
	
	//	pixels.r = pixels.r;
	//	pixels.g = mix (pixels.r, pixels.g, 0.5);
	//	pixels.b = mix (pixels.g, pixels.b, 0.75);
	
	//  Accidental Speccy palette!
	
	//	pixels.r = (float (pixels.r > 0.1));
	//	pixels.g = (float (pixels.g > 0.1));
	//	pixels.b = (float (pixels.b > 0.1));
	
	//	Same via better method...
	
	//	step function: returns 0 if second param is smaller than first param, otherwise 1...
	
	//	Results in colours like r = 1, g = 0, b = 0 -- all 1 or 0, which is how Speccy palette was set...
	
	//	pixels.r = step (0.1, pixels.r);
	//	pixels.g = step (0.1, pixels.g);
	//	pixels.b = step (0.1, pixels.b);
	
	// On Spectrum, each colour has an optional darker version at ~0.75 brightness...
		
	// step function here will return 1.0 if pixels' average < 0.1; otherwise 0. pixels is x2 here to reduce contrast
	// for less slam-to-black; the result is multiplied by 0.25 (resulting in 0.0 or 0.25) and then removed from 1.0,
	// leaving 0.75 or 1.0! All to avoid IF branches! The value 0.1 is the darkness trigger value; below 0.1 will
	// ultmately return 0.75 (for dark version of colour), otherwise we get 1.0 for standard colour...
	
	// Results are VERY sensitive to contrast of input image and trigger value! Further affected by step (0.1... ) below...
	
	float brightness = 1.0 - 0.25 * step ((pixels.r * 2.0 + pixels.b * 2.0 + pixels.g * 2.0) * 0.333, 0.1);
	
	// Multiply Spectrum-ised pixel value -- step (0.1, pixels.r) -- by result for light or dark Speccy colour:
	
	pixels = vec3 (step (0.1, pixels.r) * brightness, step (0.1, pixels.g) * brightness, step (0.1, pixels.b) * brightness);

	// D:\Documents\Development\Sources\BlitzMax Sources\openb3d stuff\GLSL Tests
	
	//	Template...
	
	//	pixels.r = pixels.r;
	//	pixels.g = pixels.g;
	//	pixels.b = pixels.b;

	gl_FragColor = vec4 (pixels, 1.0);

}
