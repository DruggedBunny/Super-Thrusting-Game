
Class HUD
	
	' This is all pretty nasty/WIP...
	
	Private
	
		Const ASSET_PREFIX_GRAPHIC:String = "asset::graphics/common/"
	
		Global FuelTextColor:Color = Color.Green ' Text colour for fuel display
		Global BlackoutAlpha:Float = 1.0
		Global BlackingOut:Bool = False
	
		Global SkullImage:Image
		
		
	Public
	
		Function Init ()
		
			If Not SkullImage Then SkullImage = Image.Load (ASSET_PREFIX_GRAPHIC + "skull.png")
			If Not SkullImage Then Abort ("HUD: Can't load skull asset!")
			
			SkullImage.Handle = New Vec2f (0.5, 0.5)

		End
		
		Function Blackout:Float (delta:Float = 0.0045)
			
			BlackingOut = True

			BlackoutAlpha = BlackoutAlpha + delta
			If BlackoutAlpha >= 1.0 Then BlackoutAlpha = 1.0
			
			Return BlackoutAlpha
			
		End
		
		Function Blackin:Float (delta:Float = 0.01)
		
			BlackingOut = False
			
			BlackoutAlpha = BlackoutAlpha - delta
			If BlackoutAlpha <= 0.0 Then BlackoutAlpha = 0.0
			
			Return BlackoutAlpha
			
		End
		
		Function ResetBlackout ()
			BlackoutAlpha = 1.0
			SkullImage?.Scale = New Vec2f (1.0, 1.0)
		End
		
		Function Render (canvas:Canvas)

			If VR_MODE
				Game.MainCamera.RenderVR (canvas)
			Endif

			' Blackout overlay...
			
			Select GameState.GetCurrentState ()
			
				Case States.PlayStarting

					' Black-in...
					
					canvas.Color = Color.Black
					canvas.Alpha = BlackoutAlpha
					canvas.DrawRect (App.ActiveWindow.Rect)
			
				Case States.PlayEnding ' Player dead...

					' Blackout...
					
					canvas.Color = Color.Black

						' Draw rect...
						
						canvas.Alpha = BlackoutAlpha
						canvas.DrawRect (App.ActiveWindow.Rect)
					
					canvas.Color = Color.White
		
						' Draw skull...
						
						SkullImage.Scale = SkullImage.Scale * 1.0075
						canvas.DrawImage (SkullImage, canvas.Viewport.Center, BlackoutAlpha * TwoPi * 4.0)
			
				Case States.LevelTween
			
					' Blackout...
					
					canvas.Color = Color.Black

						' Draw rect...
						
						canvas.Alpha = BlackoutAlpha
						canvas.DrawRect (App.ActiveWindow.Rect)
					
				Case States.Exiting

					' Blackout...
					
					canvas.Color = Color.Black
					canvas.Alpha = BlackoutAlpha
					canvas.DrawRect (App.ActiveWindow.Rect)
			
			End

			If Not (GameState.GetCurrentState () = States.LevelTween)
			
				canvas.Alpha = 1.0
				
				ShadowText (canvas, "FPS: " + App.FPS, 20.0, 20.0)
		
				ShadowText (canvas, "Left/right cursors to move Player; SPACE to boost", 20.0, 60.0)
				
				ShadowText (canvas, "R to reset!", 20.0, 80.0)
				ShadowText (canvas, "TEMP: H to halve fuel", 20.0, 100.0)
				
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
				
				If Game.CurrentLevel.Complete ()
					ShadowText (canvas, "LEVEL COMPLETE!", 20.0, 300.0)
				Endif
	
				ShadowText (canvas, "Entities in scene: " + CountEntities (), 20.0, 340.0)
				
				ShadowText (canvas, "Damage: " + Game.Player.Damage, 20.0, 380.0)
	
				
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