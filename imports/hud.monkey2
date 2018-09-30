
Class HUD
	
	' This is all pretty nasty/temp/WIP...
	
	Private
	
		Const ASSET_PREFIX_GRAPHIC:String = "asset::graphics/common/"
	
		Global FuelTextColor:Color = Color.Green ' Text colour for fuel display
		Global FadeOutAlpha:Float = 1.0
		Global FadingOut:Bool = False
	
		Global SkullImage:Image
		
		
	Public
	
		Function Init ()
		
			If Not SkullImage Then SkullImage = Image.Load (ASSET_PREFIX_GRAPHIC + "skull.png")
			If Not SkullImage Then Abort ("HUD: Can't load skull asset!")
			
			SkullImage.Handle = New Vec2f (0.5, 0.5)

		End
		
		Function FadeOut:Float (delta:Float = 0.0045)
			
			FadingOut = True

			FadeOutAlpha = FadeOutAlpha + delta
			If FadeOutAlpha >= 1.0 Then FadeOutAlpha = 1.0
			
			Return FadeOutAlpha
			
		End
		
		Function FadeIn:Float (delta:Float = 0.01)
		
			FadingOut = False
			
			FadeOutAlpha = FadeOutAlpha - delta
			If FadeOutAlpha <= 0.0 Then FadeOutAlpha = 0.0
			
			Return FadeOutAlpha
			
		End
		
		Function ResetFadeOut ()
			FadeOutAlpha = 1.0
			SkullImage?.Scale = New Vec2f (1.0, 1.0)
		End
		
		Function Render (canvas:Canvas)

			Local font:Font = canvas.Font

			If VR_MODE
				Game.MainCamera.RenderVR (canvas)
			Endif

			' FadeOut overlay...
			
			Select GameState.GetCurrentState ()
			
				Case States.PlayStarting

					' Fade in...
					
					canvas.Color = Color.Black
					canvas.Alpha = FadeOutAlpha
					canvas.DrawRect (App.ActiveWindow.Rect)
			
				Case States.PlayEnding ' Player dead...

					' Fade out...
					
					canvas.Color = Color.Black

						' Draw rect...
						
						canvas.Alpha = FadeOutAlpha
						canvas.DrawRect (App.ActiveWindow.Rect)
					
					canvas.Color = Color.White
		
						' Draw skull...
						
						SkullImage.Scale = SkullImage.Scale * 1.0075
						canvas.DrawImage (SkullImage, canvas.Viewport.Center, FadeOutAlpha * TwoPi * 4.0)
			
				Case States.LevelTween
			
					' Fade out...
					
					canvas.Color = Color.Black

						' Draw rect...
						
						canvas.Alpha = FadeOutAlpha
						canvas.DrawRect (App.ActiveWindow.Rect)
					
				Case States.Exiting

					' Fade out...
					
					canvas.Color = Color.Black
					canvas.Alpha = FadeOutAlpha
					canvas.DrawRect (App.ActiveWindow.Rect)
			
			End

			If Not (GameState.GetCurrentState () = States.LevelTween)
			
				canvas.Alpha = 1.0
				
				ShadowText (canvas, "FPS: " + App.FPS, 20.0, 20.0)
		
				ShadowText (canvas, "Left/right cursors to move Player; SPACE to boost", 20.0, 60.0)
				
				ShadowText (canvas, "R to reset!", 20.0, 80.0)
				ShadowText (canvas, "TEMP: H to halve fuel", 20.0, 120.0)
				ShadowText (canvas, "TEMP: C for next level (what was that, Continue??)", 20.0, 140.0)
				
				ShadowText (canvas, "Press A on first XBox pad to enable...", 20.0, 160.0)
				
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
				
				Local cam_dist:Float = Game.Player.RocketModel.Position.Distance (Game.MainCamera.Camera3D.Position)
				
				ShadowText (canvas, "Cam distance: " + cam_dist, 20.0, 240.0)
				ShadowText (canvas, "Cam FOV: " + Game.MainCamera.Camera3D.FOV, 20.0, 260.0)
				
'				If Game.CurrentLevel.Complete ()
'					ShadowText (canvas, "LEVEL COMPLETE!", 20.0, 300.0)
'				Endif
	
				ShadowText (canvas, "Entities in scene: " + CountEntities (), 20.0, 340.0)
				
				ShadowText (canvas, "Damage: " + Game.Player.Damage, 20.0, 380.0)

				Local current_time:String = PadDigit (Time.Now ().Hours, 2) + ":" + PadDigit (Time.Now ().Minutes, 2) + ":" + PadDigit (Time.Now ().Seconds, 2)

				ShadowText (canvas, "Time: " + current_time, canvas.Viewport.Width - 120.0, 20.0)

				ShadowText (canvas, "Master volume: " + Game.MainMixer.Level, 20.0, 420.0)
	
				ShadowText (canvas, "G for greyscale [mode: " + GreyscaleEffect.GreyModeName () + "]", 20.0, 460.0)
	
				If Game.GameState.GetCurrentState () = States.Paused
					
					Local paused:String = "P A U S E D"
					
					Local tw:Float = font.TextWidth (paused)

					ShadowText (canvas, paused, (canvas.Viewport.Width * 0.5) - (tw * 0.5), canvas.Viewport.Height * 0.65)

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

End
