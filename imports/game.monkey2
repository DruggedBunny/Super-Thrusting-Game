
Class GameWindow Extends Window

	Public

		Field terrain_seed:ULong
		Field terrain_side:Float
		
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
	
		Method SpawnRocket:Rocket (pos:Vec3f)

			Game.Player?.CurrentOrb?.Destroy ()
			Game.Player?.CurrentOrb = Null
	
			Game.Player?.Destroy ()
	
			Local rocket:Rocket = New Rocket (pos.x, pos.y, pos.z)
			
			Return rocket
	
		End
		
		Method OnCreateWindow () Override
	
			terrain_seed			= 1 ' Int (RndULong ())
			terrain_side			= 1024.0 ' Size of terrain cube sides
			
			CurrentLevel			= New Level ("test_level.txt", terrain_seed, terrain_side)
	
				If Not CurrentLevel Then Abort ("OnCreateWindow: Failed to create level!")
			
			InitScene (terrain_side)

			Local rocket_pos:Vec3f	= CurrentLevel.SpawnLevel ()
			
			Player					= SpawnRocket (rocket_pos)
			
				If Not Player Then Abort ("OnCreateWindow: SpawnRocket failed to spawn rocket!")
			
			MainCamera				= New GameCamera (App.ActiveWindow.Rect, MainCamera, terrain_side)
			
			' TODO: Not quite working, shows non-"randomly-generated level" text!
			
			If CurrentLevel.GetLevelName () = "randomly-generated level"
				Title				= AppName + " Playing randomly-generated level (seed value " + terrain_seed + ")..."
			Else
				Title				= AppName + " Playing level " + Quoted (CurrentLevel.GetLevelName ()) + "..."
			Endif
			
			game_state				= New GameState ' Can't be a property due to Getter/Setter weirdness
			
			Mouse.PointerVisible	= False
	
			HUD.Init ()
			Orb.InitOrbSound ()				' Preload sound as Orb is spawned on the fly in-game

'			PrintEntities ()

		End
	
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
		
		Method UpdateGame ()
	
			GameMenu.Control ()			' Application controls (Esc to quit, etc)

			Select GameState.GetCurrentState ()

				' -----------------------------------------------------------------
				Case States.Playing
				' -----------------------------------------------------------------
				
					If Player.Alive

						Player.Control		()			' Rocket controls
						
						MainCamera.Update	(Player)	' Update camera, follow player
						
						' TEMP!
						
					'	If CurrentLevel.Complete () ' Spawns orb at present! Stupid...
						'	Print "Level Complete!"
					'	Endif
					
					Else
						GameState.SetCurrentState (States.PlayEnding)
					Endif

				' -----------------------------------------------------------------
				Case States.PlayStarting
				' -----------------------------------------------------------------

					Player.Control		()			' Rocket controls
						
					MainCamera.Update	(Player)	' Update camera, follow player

					' Change to Playing state after HUD has blacked in...
					
					If HUD.Blackin () = 0.0
						GameState.SetCurrentState (States.Playing)
					Endif

				' -----------------------------------------------------------------
				Case States.PlayEnding ' Player dead...
				' -----------------------------------------------------------------
					
					MainCamera.Update	(Player)	' Update camera, follow player
					
					' Reset after HUD has blacked out...
					
					If HUD.Blackout () >= 1.0
						ResetLevel ()
					Endif

				' -----------------------------------------------------------------
				Case States.LevelTween ' Level complete, loading new level...
				' -----------------------------------------------------------------
					
					MainCamera.Update	(Player)	' Update camera, follow player
					
					' Reset after HUD has blacked out...
					
					If HUD.Blackout (0.01) >= 1.0
						If CurrentLevel.ExitPortal.PortalState = Portal.PORTAL_STATE_CLOSED Then ReInitLevel ()
					Endif

				' -----------------------------------------------------------------
				Case States.Exiting
				' -----------------------------------------------------------------
				
					Player.Control		()			' Rocket controls
					
					MainCamera.Update	(Player)	' Update camera, follow player
					
					' Exit after HUD has blacked out...
					
					' TODO: Not getting why this spins skull so fast!
					
					If HUD.Blackout (0.025) >= 1.0
						App.Terminate ()
					Endif
				
			End
			
		End
	
		Method ResetLevel ()

			Local rocket_pos:Vec3f = CurrentLevel.Reset ()

			Player = SpawnRocket (rocket_pos)

				If Not Player Then Abort ("OnCreateWindow: SpawnRocket failed to spawn rocket!")
			
			HUD.ResetBlackout ()

			GameState.SetCurrentState (States.PlayStarting)

			'PrintEntities ()
			
		End
		
		Method ReInitLevel ()

			terrain_seed			= terrain_seed + 1

			CurrentLevel.Destroy ()
			CurrentLevel			= New Level ("test_level.txt", terrain_seed, terrain_side)
	
				If Not CurrentLevel Then Abort ("ReInitLevel: Failed to create level!")
			
			Local rocket_pos:Vec3f	= CurrentLevel.SpawnLevel ()

			Player = SpawnRocket (rocket_pos)
			
				If Not Player Then Abort ("ReInitLevel: SpawnRocket failed to spawn rocket!")
						
			MainCamera				= New GameCamera (App.ActiveWindow.Rect, MainCamera, terrain_side)
			
			Title = AppName + " Playing level " + Quoted (CurrentLevel.GetLevelName ())

			GameState.SetCurrentState (States.PlayStarting)

			'PrintEntities ()
			
		End
		
		Method OnRender (canvas:Canvas) Override
	
			UpdateGame ()
			
			If VR_MODE
			
				renderer.Update ()
				
				MainCamera.Camera3D.SetBasis	(renderer.HeadMatrix.m, True)
				MainCamera.Camera3D.SetPosition	(renderer.HeadMatrix.t, True)
			
			Endif
			
			GameScene.Update ()
			GameScene.Render (canvas)

			HUD.Render (canvas) ' TEMP
			
			RequestRender ()
	
		End

	Private

		Field game_scene:Scene
		Field current_level:Level
	 	Field main_camera:GameCamera
		Field player:Rocket
		Field game_state:GameState

		Field renderer:VRRenderer ' VR renderer
		
End
