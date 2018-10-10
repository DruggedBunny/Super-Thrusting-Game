
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
//	gl_Position=vec4( a_Position * 2.0 - 1.0,-1.0,2.0 ); // Interesting!

}

//@fragment

const float BLOCK_SIZE = 4.0;
const float HALF_BLOCK_SIZE = BLOCK_SIZE * 0.5;

void main(){

//	vec3 pixels			= texture2D (m_SourceTexture, v_TexCoord0).rgb;

	vec3 pixels				= texture2D (m_SourceTexture, v_TexCoord0).rgb;

//		float block_align_x		= max (0.0, gl_FragCoord.x - mod (gl_FragCoord.x, BLOCK_SIZE));
//		float block_align_y		= max (0.0, gl_FragCoord.y - mod (gl_FragCoord.y, BLOCK_SIZE));
		
//		float block_center_x	= block_align_x + HALF_BLOCK_SIZE;
//		float block_center_y	= block_align_y + HALF_BLOCK_SIZE;
	
//		vec2 block_align_vec	= vec2 (block_align_x, block_align_y);
//		vec2 block_center_vec	= vec2 (block_center_x, block_center_y);
		
//		vec3 bg_pixels			= texture2D (m_SourceTexture, block_align_vec / m_SourceTextureSize).rgb;

	float src_brightness	= 1.0 - 0.25 * step ((pixels.r * 2.0 + pixels.b * 2.0 + pixels.g * 2.0) * 0.333, 0.1);

//		bg_pixels				= vec3 (step (0.1, bg_pixels.r), step (0.1, bg_pixels.g), step (0.1, bg_pixels.b)) * src_brightness;
	
	pixels					= vec3 (step (0.1, pixels.r), step (0.1, pixels.g), step (0.1, pixels.b)) * src_brightness;

	gl_FragColor = vec4 (pixels, 1.0);
	
//		gl_FragColor = vec4 (bg_pixels, 1.0);
	
}

// Commented/WIP version below...












//		vec3 pixels = texture2D (m_SourceTexture, v_TexCoord0).rgb;

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

//	The ZX Spectrum has 8 colours, plus a dark variant of each, for
//	a total of 16:
//
//	Colour		RGB
//	BLACK:		0, 0, 0
//	RED:		1, 0, 0
//	GREEN:		0, 1, 0
//	BLUE:		0, 0, 1
//	CYAN:		0, 1, 1
//	MAGENTA:	1, 0, 1
//	YELLOW:		1, 1, 0
//	WHITE:		1, 1, 1

//	Each colour has an optional darker version at ~0.75 brightness...

//	step function here will return 1.0 if pixels' average < 0.1; otherwise 0. pixels is x2 here to reduce contrast
//	for less slam-to-black; the result is multiplied by 0.25 (resulting in 0.0 or 0.25) and then removed from 1.0,
//	leaving 0.75 or 1.0.... all to avoid IF branches! The value 0.1 is the darkness trigger value; below 0.1 will
//	ultmately return 0.75 (for dark version of colour), otherwise we get 1.0 for standard colour...

//	Results are VERY sensitive to contrast of input image and trigger value! Further affected by step (0.1... ) below...

//		float brightness = 1.0 - 0.25 * step ((pixels.r * 2.0 + pixels.b * 2.0 + pixels.g * 2.0) * 0.333, 0.1);

//		"Optimised" to...

//		float brightness	= 1.0 - 0.25 * step (pixels * 2.0 * 0.333, vec3(0.1)).r; // r, g and b are all same here so take .r from vec3 version of step ()!

// Multiply Spectrum-ised pixel value -- step (0.1, pixels.r) -- by result for light or dark Speccy colour:

//		pixels = vec3 (step (0.1, pixels.r) * brightness, step (0.1, pixels.g) * brightness, step (0.1, pixels.b) * brightness);

//		gl_FragColor = vec4 (pixels, 1.0);
