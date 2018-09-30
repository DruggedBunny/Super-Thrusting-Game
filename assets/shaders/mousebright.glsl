
//@renderpasses 0

uniform sampler2D m_SourceTexture;
uniform vec2 m_SourceTextureSize;
uniform vec2 m_SourceTextureScale;
uniform float m_MousePos;

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

	gl_FragColor = vec4 (pixels * m_MousePos, 1.0);

//	gl_FragColor = vec4 (1.0, 0.0, 1.0, 1.0);
	
}
