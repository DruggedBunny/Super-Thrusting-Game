
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' Main game control, specifically allowed to amend and call main Game application properties.

' Mainly intended to simplify Game class.

' This handles core game control and rendering, as well as level/scene changes.

Class GameController

	Field last_timescale:Float
	
	Method ProcessGame ()

		Game.Player.PerLoopReset ()
		
		Game.GameTimer.Update ()

		GameMenu.Control ()									' Application controls (Esc to quit, etc)

		Game.CurrentLevel.Update ()

		Game.MainMixer.UpdateFaders ()
		
		Select GameState.GetCurrentState ()

			Case States.Paused
				
'				If Game.MainMixer.MasterVolume > 0.0
'					Game.MainMixer.MasterVolume = Blend (Game.MainMixer.MasterVolume, 0.0, 0.2)
'				Endif
				
				If Not Game.MainMixer.Paused Then Game.MainMixer.Paused = True

				If Game.GameScene.UpdateRate
'					last_timescale = Game.GameScene.UpdateRate
					Game.GameScene.UpdateRate = 0.0
				Endif
				
			' -----------------------------------------------------------------
			Case States.Playing
			' -----------------------------------------------------------------

'				If Game.MainMixer.MasterVolume < 1.0
'					Game.MainMixer.MasterVolume = Blend (Game.MainMixer.MasterVolume, 1.0, 0.2)
'				Endif
	
				If Game.MainMixer.Paused Then Game.MainMixer.Paused = False

				If Not Game.GameScene.UpdateRate
					Game.GameScene.UpdateRate = last_timescale
				Endif

				If Game.Player.Alive
					Game.Player.Control		()				' Rocket controls
					Game.MainCamera.Update	(Game.Player)	' Update camera, follow player
				Else
					GameState.SetCurrentState (States.PlayEnding)
				Endif

			' -----------------------------------------------------------------
			Case States.PlayStarting
			' -----------------------------------------------------------------

				If Game.MainMixer.Level < 1.0
					Game.MainMixer.Level = Blend (Game.MainMixer.Level, 1.0, 0.01)
				Endif

'				Game.GameScene.World.TimeScale = 1.0

				Game.Player.Control		()					' Rocket controls
				Game.MainCamera.Update	(Game.Player)		' Update camera, follow player

				' Change to Playing state after HUD has faded-in...
				
				Local TMP_FADE:Float = 0.05
				
				If Game.HUD.FadeIn (TMP_FADE) = 0.0
					' Just to make sure...
					Game.MainMixer.Level = 1.0
					GameState.SetCurrentState (States.Playing)
				Endif

			' -----------------------------------------------------------------
			Case States.PlayEnding ' Player dead...
			' -----------------------------------------------------------------
				
				If Game.MainMixer.Level > 0.0
					Game.MainMixer.Level = Blend (Game.MainMixer.Level, 0.0, 0.02)
				Endif
				
				Game.MainCamera.Update	(Game.Player)		' Update camera, follow player
				
				' Reset after HUD has faded out...
				
				Local hud_fade:Float = Game.HUD.FadeOut ()
				
'				If Game.GameScene.World.TimeScale > 0.25 Then Game.GameScene.World.TimeScale = Game.GameScene.World.TimeScale * 0.99
				
				If hud_fade >= 1.0
					Game.Controller.ResetLevel ()
				Endif

			' -----------------------------------------------------------------
			Case States.LevelTween ' Level complete, loading new level...
			' -----------------------------------------------------------------
				
				Game.MainCamera.Update	(Game.Player)		' Update camera, follow player
				
				' Reset after HUD has faded out...
				
				Local rate:Float = 0.01
				
				If Game.MainMixer.Level > 0.0
					Game.MainMixer.Level = Blend (Game.MainMixer.Level, 0.0, 0.02)
				Endif

				Game.Player.CurrentOrb?.FadeAudio (rate)
				Game.CurrentLevel.Dummy?.FadeAudio (rate)

				If Game.HUD.FadeOut (rate) >= 1.0
					If Game.CurrentLevel.ExitPortal.PortalState = Portal.PORTAL_STATE_CLOSED
						SpawnNextLevel ()
					Endif
				Endif

			' -----------------------------------------------------------------
			Case States.Exiting
			' -----------------------------------------------------------------
			
				Game.Player.Control		()					' Rocket controls
				Game.MainCamera.Update	(Game.Player)		' Update camera, follow player
				
				' Exit after HUD has faded out...
				
				If Game.HUD.FadeOut (0.025) >= 1.0
					App.Terminate ()
				Endif
			
		End
		
	End
		
	' --------------------------------------------------------------------
	' Reset level after player dies...
	' --------------------------------------------------------------------

	Method ResetLevel ()

		Local rocket_pos:Vec3f = Game.CurrentLevel.Reset ()

		Game.Player = SpawnRocket (rocket_pos)

			If Not Game.Player Then Abort ("ResetLevel: SpawnRocket failed to spawn rocket!")
		
		GameState.SetCurrentState (States.PlayStarting)

		'MainMixer.PrintFaders ()
		
	End

	' --------------------------------------------------------------------
	' Spawn new player...
	' --------------------------------------------------------------------

	Method SpawnRocket:Rocket (pos:Vec3f)

		Game.Player?.Destroy ()

		Return New Rocket (pos.x, pos.y, pos.z)
		
	End

	' --------------------------------------------------------------------
	' Level complete! Next!
	' --------------------------------------------------------------------

	Method SpawnNextLevel ()

		Game.CurrentLevel.Destroy ()
		
		Game.TerrainSeed			= Game.TerrainSeed + 1

		Game.CurrentLevel			= New Level (Game.TerrainSeed, Game.TerrainSize)

			If Not Game.CurrentLevel Then Abort ("SpawnNextLevel: Failed to create level!")
		
		Local rocket_pos:Vec3f		= Game.CurrentLevel.SpawnLevel ()

		Game.Player					= SpawnRocket (rocket_pos)
		
			If Not Game.Player Then Abort ("SpawnNextLevel: SpawnRocket failed to spawn rocket!")
					
		Game.MainCamera				= New GameCamera (App.ActiveWindow.Rect, Game.MainCamera, Game.TerrainSize)
		
		Game.HUD					= New HUDOverlay ' HUD needs to pick up new camera

		Game.SetWindowTitle ()
		
		GameState.SetCurrentState (States.PlayStarting)

	End

	Method Render (canvas:Canvas)
			
		' ----------------------------------------------------------------
		' VR-only:
		' ----------------------------------------------------------------
		
		If VR_MODE
		
			Game.VR_Renderer.Update () ' Get VR headset position, etc...
			
			' Position camera according to headset rotation/position...
			
			Game.MainCamera.Camera3D.SetBasis		(Game.VR_Renderer.HeadMatrix.m, True)
			Game.MainCamera.Camera3D.SetPosition	(Game.VR_Renderer.HeadMatrix.t, True)
		
		Endif
		
		' ----------------------------------------------------------------
		' Update scene (mainly physics)...
		' ----------------------------------------------------------------

		Game.GameScene.Update ()

		' ----------------------------------------------------------------
		' Render scene to canvas...
		' ----------------------------------------------------------------
		
		Game.GameScene.Render (canvas)

		'Local px:Pixmap = canvas.CopyPixmap (canvas.Viewport)
		'canvas.Resize (New Vec2i (canvas.Viewport.Width * 0.25, canvas.Viewport.Height * 0.25))
		
'			Local img:Image = New Image (px)
		
'			canvas.DrawImage (img, 0, 0, 0, 0.5, 0.5)
		
		If Game.HUD.GemMapVisible

			Game.CurrentLevel.CurrentGemMap.Update ()
			
			canvas.Alpha = 0.75
			canvas.DrawImage (Game.CurrentLevel.CurrentGemMap.GemMapImage, canvas.Viewport.Width - Game.CurrentLevel.CurrentGemMap.GemMapImage.Width, canvas.Viewport.Height - Game.CurrentLevel.CurrentGemMap.GemMapImage.Height)
			canvas.Alpha = 1.0
		
		Endif
		
		' ----------------------------------------------------------------
		' Overlay HUD...
		' ----------------------------------------------------------------

		Game.HUD.Render (canvas) ' TEMP
		
	End

	' --------------------------------------------------------------------
	' Scene setup...
	' --------------------------------------------------------------------

	Method InitScene (terrain_size:Float)

		Game.GameScene					= Scene.GetCurrent ()
		Game.GameScene.World.Gravity 	= Game.GameScene.World.Gravity * New Vec3f (1.0, 0.5, 1.0) ' Half normal gravity
		Game.GameScene.CSMSplits		= New Float [] (2, 4, 16, 256)

		SetFogColor ()
		SetFogRange (96.0, terrain_size)
		
		SetAmbientLight ()
		
		Game.PixelShaders				= New List <PostEffectPlus>
		
		Game.GreyscaleShader			= New GreyscaleEffect (3) ' Greyscale mode 3 (Luminosity)
		Game.SpeccyShader				= New SpeccyEffect ()
		Game.MonoShader					= New MonoEffect ()

		Game.PixelShaders.Add (Game.GreyscaleShader)
		Game.PixelShaders.Add (Game.SpeccyShader)
		Game.PixelShaders.Add (Game.MonoShader)
		
		If VR_MODE
			Game.VR_Renderer = New VRRenderer
		Endif

	End
	
	' --------------------------------------------------------------------
	' Set setup helper functions...
	' --------------------------------------------------------------------

	Method SetFogColor (clear_color:Color = Color.Sky * 0.5)
		Game.GameScene.ClearColor	= clear_color
		Game.GameScene.FogColor		= clear_color
	End
	
	Method SetAmbientLight (ambient_color:Color = Color.White * 0.75)
		Game.GameScene.AmbientLight = ambient_color
	End
	
	Method SetFogRange (near:Float, far:Float)
		Game.GameScene.FogNear	= near
		Game.GameScene.FogFar	= far
	End
		
End
