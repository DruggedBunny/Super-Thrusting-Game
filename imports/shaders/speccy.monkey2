
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
'			uniforms.SetVec2f	("SourceTextureSize",	rtexture.Size)
			uniforms.SetVec2f	("SourceTextureScale",	Cast <Vec2f> (rviewport.Size) / Cast <Vec2f> (rtexture.Size))
			
			Device.BlendMode			= BlendMode.Opaque
			Device.RenderPass			= 0
			
			RenderQuad ()
			
		End
	
End
