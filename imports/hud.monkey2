
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' In-game display/overlay. Bit of a mess, very "WIP" and temporary!

Class HUDOverlay
	
	Public
	
		Property GemMapVisible:Bool ()
			Return gem_map_visible
			Setter (state:Bool)
				gem_map_visible = state
		End
		
		Method New ()
		
			sprite_start_scale	= New Vec3f (0.05, 0.05, 1.0)
			
			SkullSprite			= New Sprite (SpriteMaterial.Load (ASSET_PREFIX_GRAPHIC + "skull.png"), Game.MainCamera.Camera3D)
			
				If Not SkullSprite Then Abort ("HUD: Can't load skull asset!")
			
			SkullSprite.Move (0.0, 0.0, 1.0)
			
			SkullSprite.Mode	= SpriteMode.Fixed
			SkullSprite.Scale	= sprite_start_scale
			SkullSprite.Visible	= False
			
		End
		
		Method FadeOut:Float (delta:Float = 0.004)
			
			FadingOut = True

			FadeAlpha = FadeAlpha + (delta * Game.Delta)
			
			If FadeAlpha >= 1.0 Then FadeAlpha = 1.0
			
			Return FadeAlpha
			
		End
		
		Method FadeIn:Float (delta:Float = 0.01)
		
			FadingOut = False
			
			FadeAlpha = FadeAlpha - (delta * Game.Delta)
			
			If FadeAlpha <= 0.0 Then FadeAlpha = 0.0
			
			Return FadeAlpha
			
		End
		
		Method Render (canvas:Canvas)

			Local font:Font = canvas.Font

			If VR_MODE
				Game.MainCamera.RenderVR (canvas)
			Endif

			' FadeOut overlay...
			
			Select GameState.GetCurrentState ()
			
				Case States.PlayStarting

					If SkullSprite.Visible
					
						SkullSprite.Visible		= False
						SkullSprite.Scale		= sprite_start_scale
						SkullSprite.Rotation	= New Vec3f (0.0, 0.0, 0.0)
						
					Endif
					
					' Fade in...
					
					canvas.Color = Color.Black
					canvas.Alpha = FadeAlpha
					canvas.DrawRect (App.ActiveWindow.Rect)
			
				Case States.PlayEnding ' Player dead...

					' Fade out...
					
					canvas.Color = Color.Black

						' Draw rect...
						
						canvas.Alpha = FadeAlpha
						canvas.DrawRect (App.ActiveWindow.Rect)
					
					canvas.Color = Color.White
		
						' Draw skull...
						
						If Not SkullSprite.Visible
							SkullSprite.Visible = True
						Endif

						SkullSprite.Scale		= SkullSprite.Scale * 1.025 * Game.Delta
						SkullSprite.Rotation	= Game.MainCamera.Camera3D.Rotation + New Vec3f (0.0, 0.0, SkullSprite.Rotation.Z + 5.0)
						
'						If quad_mode = SpriteMode.Billboard
			
				Case States.LevelTween
			
					' Fade out...
					
					canvas.Color = Color.Black

						' Draw rect...
						
						canvas.Alpha = FadeAlpha
						canvas.DrawRect (App.ActiveWindow.Rect)
					
				Case States.Exiting

					' Fade out...
					
					canvas.Color = Color.Black
					canvas.Alpha = FadeAlpha
					canvas.DrawRect (App.ActiveWindow.Rect)
			
			End

			If Not (GameState.GetCurrentState () = States.LevelTween)
			
				canvas.Alpha = 1.0
				
				ShadowText (canvas, "FPS: " + App.FPS, 20.0, 20.0)
				ShadowText (canvas, "Left/right cursors to move Player; SPACE to boost, or use an attached Xbox pad", 20.0, 60.0)
				ShadowText (canvas, "P to pause", 20.0, 80.0)
				ShadowText (canvas, "TEMP: R to reset!", 20.0, 100.0)
				ShadowText (canvas, "TEMP: N for next level", 20.0, 140.0)
			
				If Game.Player.Fuel = 0.0
					FuelTextColor = Color.Grey
				Elseif Game.Player.Fuel > 50.0
					FuelTextColor = Color.Green
				Elseif Game.Player.Fuel <= 25.0
					FuelTextColor = Color.Red
				Elseif Game.Player.Fuel <= 50.0
					FuelTextColor = Color.Orange
				Endif
				
				canvas.Color = Color.White
		
				ShadowText (canvas, "Space gems: " + Game.CurrentLevel.SpaceGemsCollected + " / " + Game.CurrentLevel.SpaceGemCount, 20.0, 200)
				ShadowText (canvas, "Fuel: " + Int (Game.Player.Fuel), 20.0, 220.0, FuelTextColor)
				ShadowText (canvas, "TEMP: Entities in scene: " + CountEntities (), 20.0, 340.0)
				ShadowText (canvas, "Damage: " + Game.Player.Damage, 20.0, 380.0)

				Local current_time:String = PadDigit (Time.Now ().Hours, 2) + ":" + PadDigit (Time.Now ().Minutes, 2) + ":" + PadDigit (Time.Now ().Seconds, 2)

				ShadowText (canvas, "Time: " + current_time, canvas.Viewport.Width - 120.0, 20.0)
				ShadowText (canvas, "F1: disable pixel shaders", 20.0, 460.0)
				ShadowText (canvas, "F2: toggle greyscale shader", 20.0, 480.0)
				ShadowText (canvas, "F3: toggle [WIP] Spectrum shader", 20.0, 500.0)
				ShadowText (canvas, "F4: toggle B&W (mono) shader", 20.0, 520.0)
				ShadowText (canvas, "M to toggle Space Gem map", 20.0, 560.0)

				If Game.GameState.GetCurrentState () = States.Paused
					
					Local paused:String = "P A U S E D"

					ShadowText (canvas, paused, (canvas.Viewport.Width * 0.5) - (font.TextWidth (paused) * 0.5), canvas.Viewport.Height * 0.65)

				Else
				
					If Game.Player.Refueling
					
						Local paused:String = "R E F U E L I N G . . ."

						ShadowText (canvas, paused, (canvas.Viewport.Width * 0.5) - (font.TextWidth (paused) * 0.5), canvas.Viewport.Height * 0.65)

					Endif
					
				Endif
				
'				Local nearest:Float = 1000000.0
'				
'				For Local gem:SpaceGem = Eachin Game.CurrentLevel.GemList
'					
'					' TODO: Remember why SpaceGemModel () is a method... ???
'					
'					If gem.GetSpaceGemModel ().Position.Distance (Game.Player.RocketModel.Position) < nearest
'						nearest = gem.GetSpaceGemModel ().Position.Distance (Game.Player.RocketModel.Position)
'					Endif
'					
'				Next
'				
'				ShadowText (canvas, "Nearest Space Gem: " + nearest, 20.0, 420.0)
'				
	'			ShadowText (canvas, Game.Player.RocketModel.LocalRx, 200, 340)
	'			ShadowText (canvas, Game.Player.RocketModel.LocalRy, 200, 360)
	'			ShadowText (canvas, Game.Player.RocketModel.GetRotation ().Z, 200, 380)
				
				'ShadowText (canvas, Game.Player.RocketModel.Position, 200, 300)
		'		ShadowText (canvas, "vel: " + Game.Player.RocketBody.LinearVelocity.Normalize (), 20.0, 240.0)
		'		ShadowText (canvas, "rot: " + Game.Player.RocketModel.Rotation.Normalize (), 20.0, 260.0)

			Else
				
				ShadowText (canvas, "LEVEL COMPLETE! Loading new level... ", 20.0, 20.0)
				
			Endif
			
		End

	' This is all pretty nasty/temp/WIP...
	
	Private
	
		Const ASSET_PREFIX_GRAPHIC:String = "asset::graphics/common/"
	
		Global FuelTextColor:Color	= Color.Green ' Text colour for fuel display
		Global FadeAlpha:Float		= 1.0
		Global FadingOut:Bool		= False
	
		Global SkullSprite:Sprite
		
		Field sprite_start_scale:Vec3f ' TEMP

		Field gem_map_visible:Bool = True

End
