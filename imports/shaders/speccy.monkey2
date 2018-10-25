
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' A pixel shader implementing the Sinclair ZX Spectrum graphics palette.

' TODO: Figure out how to render as 256 x 192 and scale to current display
' size; then implement 'attribute' clash -- impractical with 1080p (have to
' scan 8x8 pixel blocks and determine most-used colours), but might work at
' very low res like Spectrum's!

' Shaders are loaded from "Assets::shaders/" -- Shader.Open adds ".glsl" to
' the shader name if not provided.

' NB. The actual shader processing code is located within the associated .glsl
' file, using the OpenGL GLSL language.

Class SpeccyEffect Extends PostEffectPlus

	Method New ()
		
		shader		= Shader.Open ("speccy")
		
		uniforms	= New UniformBlock (3)

	End

	Private
	
		Field shader:Shader
		Field uniforms:UniformBlock
		
	Protected
	
		Method OnRender (rtarget:RenderTarget, rviewport:Recti) Override
			
			Local rtexture:Texture		= rtarget.GetColorTexture (0)
			
			Device.Shader				= shader
			Device.BindUniformBlock (uniforms)
	
			uniforms.SetTexture	("SourceTexture",		rtexture)
			uniforms.SetVec2f	("SourceTextureSize",	rtexture.Size)
			uniforms.SetVec2f	("SourceTextureScale",	Cast <Vec2f> (rviewport.Size) / Cast <Vec2f> (rtexture.Size))
			
			Device.BlendMode			= BlendMode.Opaque
			Device.RenderPass			= 0
			
			RenderQuad ()
			
		End
	
End
