
Class GameWindow Extends Window

	Public

		' Temp: Used only by GameMenu.Control -> R or Gamepad Start to reset level during development!
		
		Method TMP_ResetLevel ()
			ResetLevel ()
		End
		
		Property VR_Renderer:VRRenderer ()
			Return renderer
		End
		
		Property GameState:GameState ()
			Return game_state
			Setter (state:GameState)
				game_state = state
		End
		
		Property GameScene:Scene ()
			Return game_scene
			Setter (scene:Scene)
				game_scene = scene
		End
		
	 	Property MainCamera:GameCamera ()
	 		Return main_camera
	 		Setter (camera:GameCamera)
	 			main_camera = camera
	 	End
	 	
		Property CurrentLevel:Level ()
			Return current_level
			Setter (level:Level)
				current_level = level
		End
		
		Property Player:Rocket ()
			Return player
			Setter (new_player:Rocket)
				player = new_player
		End

		Method New (title:String, width:Int, height:Int, flags:WindowFlags)	
			Super.New (title, width, height, flags)
		End
	
		Method OnCreateWindow () Override
	
			' ----------------------------------------------------------------
			' Terrain, level and scene setup...
			' ----------------------------------------------------------------
			
			terrain_seed			= 0			' Test: Int (RndULong ())
			terrain_side			= 1024.0	' Size of terrain cube sides
			
			CurrentLevel			= New Level (terrain_seed, terrain_side)
	
				If Not CurrentLevel Then Abort ("OnCreateWindow: Failed to create level!")
			
			InitScene (terrain_side)

			' ----------------------------------------------------------------
			' Player setup...
			' ----------------------------------------------------------------

			Local rocket_pos:Vec3f	= CurrentLevel.SpawnLevel ()
			
			Player					= SpawnRocket (rocket_pos)
			
				If Not Player Then Abort ("OnCreateWindow: SpawnRocket failed to spawn rocket!")
			
			' ----------------------------------------------------------------
			' Camera setup...
			' ----------------------------------------------------------------

			MainCamera				= New GameCamera (App.ActiveWindow.Rect, MainCamera, terrain_side)
			
			' ----------------------------------------------------------------
			' Set window title...
			' ----------------------------------------------------------------
			
			' TODO: Not quite working, shows non-"randomly-generated level" text!
			
			If CurrentLevel.GetLevelName () = "randomly-generated level"
				Title				= AppName + " Playing randomly-generated level (seed value " + terrain_seed + ")..."
			Else
				Title				= AppName + " Playing level " + Quoted (CurrentLevel.GetLevelName ()) + "..."
			Endif
			
			' ----------------------------------------------------------------
			' Hide mouse pointer...
			' ----------------------------------------------------------------

			Mouse.PointerVisible	= False
	
			' ----------------------------------------------------------------
			' Init HUD (TODO: Use an object instead of class functions)...
			' ----------------------------------------------------------------

			HUD.Init ()

			' ----------------------------------------------------------------
			' Special case -- orb sound pre-loaded...
			' ----------------------------------------------------------------

			Orb.InitOrbSound ()				' Preload sound as Orb is spawned on the fly in-game

			' ----------------------------------------------------------------
			' Init gameloop...
			' ----------------------------------------------------------------

			game_controller			= New GameController
	
			' ----------------------------------------------------------------
			' Init game state...
			' ----------------------------------------------------------------

			game_state				= New GameState ' Can't be a property due to Getter/Setter weirdness
			
		End
	
		Method OnRender (canvas:Canvas) Override
		
			' ----------------------------------------------------------------
			' Effectively, run main loop, managing game state:
			' ----------------------------------------------------------------
			
			game_controller.ProcessGame ()
			
			' ----------------------------------------------------------------
			' VR-only:
			' ----------------------------------------------------------------
			
			If VR_MODE
			
				renderer.Update () ' Get VR headset position, etc...
				
				' Position camera according to headset rotation/position...
				
				MainCamera.Camera3D.SetBasis	(renderer.HeadMatrix.m, True)
				MainCamera.Camera3D.SetPosition	(renderer.HeadMatrix.t, True)
			
			Endif
			
			' ----------------------------------------------------------------
			' Update scene (mainly physics)...
			' ----------------------------------------------------------------

			GameScene.Update ()

			' ----------------------------------------------------------------
			' Render scene to canvas...
			' ----------------------------------------------------------------

			GameScene.Render (canvas)

			' ----------------------------------------------------------------
			' Overlay HUD...
			' ----------------------------------------------------------------

			HUD.Render (canvas) ' TEMP
			
			' ----------------------------------------------------------------
			' Tell system we are ready to draw this scene frame...
			' ----------------------------------------------------------------

			RequestRender ()
	
		End

		' --------------------------------------------------------------------
		' Spawn new player...
		' --------------------------------------------------------------------

		Method SpawnRocket:Rocket (pos:Vec3f)

			Game.Player?.Destroy ()
	
			Return New Rocket (pos.x, pos.y, pos.z)
			
		End
		
		' --------------------------------------------------------------------
		' Reset level after player dies...
		' --------------------------------------------------------------------

		Method ResetLevel ()

			Local rocket_pos:Vec3f = CurrentLevel.Reset ()

			Player = SpawnRocket (rocket_pos)

				If Not Player Then Abort ("ResetLevel: SpawnRocket failed to spawn rocket!")
			
			HUD.ResetFadeOut ()

			GameState.SetCurrentState (States.PlayStarting)

		End
		
		' --------------------------------------------------------------------
		' Level complete! Next!
		' --------------------------------------------------------------------

		Method SpawnNextLevel ()

			CurrentLevel.Destroy ()
			
			terrain_seed			= terrain_seed + 1

			CurrentLevel			= New Level (terrain_seed, terrain_side)
	
				If Not CurrentLevel Then Abort ("SpawnNextLevel: Failed to create level!")
			
			Local rocket_pos:Vec3f	= CurrentLevel.SpawnLevel ()

			Player = SpawnRocket (rocket_pos)
			
				If Not Player Then Abort ("SpawnNextLevel: SpawnRocket failed to spawn rocket!")
						
			MainCamera				= New GameCamera (App.ActiveWindow.Rect, MainCamera, terrain_side)
			
			Title = AppName + " Playing level " + Quoted (CurrentLevel.GetLevelName ())

			GameState.SetCurrentState (States.PlayStarting)

		End
		
	Private

		' --------------------------------------------------------------------
		' Scene setup...
		' --------------------------------------------------------------------

		Method InitScene (terrain_side:Float)
	
			GameScene					= Scene.GetCurrent ()
			GameScene.World.Gravity 	= GameScene.World.Gravity * New Vec3f (1.0, 0.5, 1.0) ' Half normal gravity
			GameScene.CSMSplits			= New Float [] (2, 4, 16, 256)

			SetFogColor ()
			SetFogRange (96.0, terrain_side)
			
			SetAmbientLight ()
			
			If VR_MODE
				renderer = New VRRenderer
			Endif
	
		End
		
		' --------------------------------------------------------------------
		' Set setup helper functions...
		' --------------------------------------------------------------------

		Method SetFogColor (clear_color:Color = Color.Sky * 0.75)
			GameScene.ClearColor	= clear_color
			GameScene.FogColor		= clear_color
		End
		
		Method SetAmbientLight (ambient_color:Color = Color.White * 0.75)
			GameScene.AmbientLight = ambient_color
		End
		
		Method SetFogRange (near:Float, far:Float)
			GameScene.FogNear	= near
			GameScene.FogFar	= far
		End
		
		Field game_scene:Scene
		Field current_level:Level
	 	Field main_camera:GameCamera
		Field player:Rocket
		Field game_state:GameState

		Field game_controller:GameController
		
		Field terrain_seed:ULong
		Field terrain_side:Float
		
		Field renderer:VRRenderer ' VR renderer
		
End
