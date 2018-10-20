
Class PostEffectPlus Extends PostEffect
	
	Property Active:Bool ()
		Return active
	End

	Field active:Bool
	
	Function Clear ()

		For Local pe:PostEffectPlus = Eachin Game.PixelShaders
		
			If pe.Active
				Game.GameScene.RemovePostEffect (pe)
				pe.active = Not pe.active
			Endif

		Next
		
	End
	
	Method Toggle ()
	
		For Local pe:PostEffectPlus = Eachin Game.PixelShaders
		
			' Remove any other pixel shaders...
			
			If pe <> Self
				If pe.Active
					Game.GameScene.RemovePostEffect (pe)
					pe.active = Not pe.active
				Endif
			Endif

		Next
		
		' Toggle this shader...
		
		If Not Active
			Game.GameScene.AddPostEffect (Self)
			active = Not active
		Else
			Game.GameScene.RemovePostEffect (Self)
			active = Not active
		Endif
		
	End
	
End
