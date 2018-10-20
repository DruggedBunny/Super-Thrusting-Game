
Class MonoEffect Extends PostEffectPlus

	Method New (mode:Int = 0)
		
		shader		= Shader.Open ("mono")
		
		uniforms	= New UniformBlock (3)

	End
	
	Private
	
		Field shader:Shader
		Field uniforms:UniformBlock
		
		Field texture:Texture
		Field target:RenderTarget
	
	Protected
	
		Method OnRender (rtarget:RenderTarget, rviewport:Recti) Override
			
'			Local rviewport:Vec2i			= Device.Viewport.Size
'			Local rtarget:RenderTarget	= Device.RenderTarget
			Local rtexture:Texture		= rtarget.GetColorTexture (0)
			
			If Not target Or rviewport.X > target.Size.X Or rviewport.Y > target.Size.Y
			
				texture?.Discard ()
				target?.Discard ()
			
				texture	= New Texture (rviewport.X, rviewport.Y, rtexture.Format, TextureFlags.Dynamic | TextureFlags.Filter)
				target	= New RenderTarget (New Texture [] (texture), Null)
				
			Endif
	
			Device.Shader = shader
			Device.BindUniformBlock (uniforms)
	
			Local target:RenderTarget	= target
			Local source:Texture		= rtexture
			
			uniforms.SetTexture		("SourceTexture", source)
			uniforms.SetVec2f		("SourceTextureSize", source.Size)
			uniforms.SetVec2f		("SourceTextureScale", Cast <Vec2f> (rviewport.Size) / Cast <Vec2f> (source.Size))
			
			Device.BlendMode	= BlendMode.Opaque
			Device.RenderPass	= 0
			
			RenderQuad ()
			
		End
	
End
