
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

bool StippleMask ()
{
	// Original by Ashaman73: https://www.gamedev.net/blogs/entry/2154392-alpha-transparency-in-deferred-shader/
	
	vec2 stipple = fract (gl_FragCoord.xy * 0.5);
	return bool (step (0.25, abs (stipple.x - stipple.y)));
}

void main(){

	vec3 pixels = texture2D (m_SourceTexture, v_TexCoord0).rgb;

	float average = (pixels.r + pixels.g + pixels.b) * 0.333;

	vec3 black = vec3 (0.0, 0.0, 0.0);
	vec3 white = vec3 (1.0, 1.0, 1.0);
	
	if (average > 0.2)
	{
		pixels = white;
	}
	else
	{
		if (average > 0.045)
		{
			if (StippleMask ())
			{
				pixels = white;
			}
			else
			{
				pixels = black;
			}	
		}
		else
		{
			pixels = black;
		}
	}
	
	gl_FragColor = vec4 (pixels, 1.0);
	
}
