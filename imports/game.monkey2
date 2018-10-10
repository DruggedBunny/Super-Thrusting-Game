
Class GameWindow Extends Window

	Public
		
		Property GemMapVisible:Bool ()
			Return gem_map_visible
			Setter (state:Bool)
				gem_map_visible = state
		End
		
		Property PixelShaders:List <PostEffectPlus> ()
			Return pixel_shaders
		End
		
		Property GreyscaleShader:PostEffectPlus ()
			Return grey
		End

		Property SpeccyShader:PostEffectPlus ()
			Return speccy
		End

		Property MainMixer:Mixer ()
			Return main_mixer
			Setter (in_mixer:Mixer)
				main_mixer = in_mixer
		End
		
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

		Property TMP_Canvas:Canvas ()
			Return tmp_canvas
		End
		
		Field tmp_image:Image
		
		Field tmp_canvas:Canvas
		
		Method New (title:String, width:Int, height:Int, flags:WindowFlags)	
			Super.New (title, width, height, flags | WindowFlags.Resizable)
		End
	
		Method OnCreateWindow () Override

			tmp_image = New Image (256, 192, PixelFormat.RGBA8, TextureFlags.Dynamic)
			tmp_canvas = New Canvas (tmp_image)

			MainMixer					= New Mixer

				MainMixer.Level			= 0.0
			
			' ----------------------------------------------------------------
			' Pre-load sounds...
			' ----------------------------------------------------------------

			Orb.		InitSound ()
			DummyOrb.	InitSound ()
			Rocket.		InitSound ()
			Wall.		InitSound ()
			Portal.		InitSound ()
			SpaceGem.	InitSound ()
			
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
			
			SetWindowTitle ()
			
			' ----------------------------------------------------------------
			' Hide mouse pointer...
			' ----------------------------------------------------------------

			Mouse.PointerVisible	= False
	
			' ----------------------------------------------------------------
			' Init HUD (TODO: Use an object instead of class functions)...
			' ----------------------------------------------------------------

			HUD.Init ()

			' ----------------------------------------------------------------
			' Init gameloop...
			' ----------------------------------------------------------------

			game_controller			= New GameController
	
			' ----------------------------------------------------------------
			' Init game state...
			' ----------------------------------------------------------------

			game_state				= New GameState ' Can't be a property due to Getter/Setter weirdness

			last_state				= game_state.GetCurrentState ()

			App.Activated			+=	Lambda ()
											Print "Activated"
											GameState.SetCurrentState (last_state)
										End
		
			App.Deactivated			+=	Lambda ()
											Print "Deactivated"
											last_state = GameState.GetCurrentState ()
											GameState.SetCurrentState (States.Paused)
										End
			
			' Mixer debug...
			' MainMixer.PrintFaders ()

			test_img = New Image (256, 256)
			test_cnv = New Canvas (test_img)

			'Print GetConfig ("MOJO3D_RENDERER")
			'Print opengl.glGetString (opengl.GL_VERSION)
			
		End

		Method SetWindowTitle ()
		
			If CurrentLevel.LevelName = ""
				Title = AppName + " Playing randomly-generated level (seed value " + terrain_seed + ")..."
			Else
				Title = AppName + " Playing level " + Quoted (CurrentLevel.LevelName) + "..."
			Endif

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

			'Local px:Pixmap = canvas.CopyPixmap (canvas.Viewport)
			'canvas.Resize (New Vec2i (canvas.Viewport.Width * 0.25, canvas.Viewport.Height * 0.25))
			
'			Local img:Image = New Image (px)
			
'			canvas.DrawImage (img, 0, 0, 0, 0.5, 0.5)
			
			If GemMapVisible

				Game.CurrentLevel.CurrentGemMap.Update ()
				
				canvas.Alpha = 0.75
				canvas.DrawImage (Game.CurrentLevel.CurrentGemMap.GemMapImage, canvas.Viewport.Width - Game.CurrentLevel.CurrentGemMap.GemMapImage.Width, canvas.Viewport.Height - Game.CurrentLevel.CurrentGemMap.GemMapImage.Height)
				canvas.Alpha = 1.0
			
			Endif
			
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

			'MainMixer.PrintFaders ()
			
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
			
			SetWindowTitle ()
			
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
			
			pixel_shaders				= New List <PostEffectPlus>
			
			grey						= New GreyscaleEffect (3) ' Greyscale mode 3 (Luminosity)
			speccy						= New SpeccyEffect ()

			pixel_shaders.Add (grey)
			pixel_shaders.Add (speccy)
			
			If VR_MODE
				renderer = New VRRenderer
			Endif
	
		End
		
		' --------------------------------------------------------------------
		' Set setup helper functions...
		' --------------------------------------------------------------------

		Method SetFogColor (clear_color:Color = Color.Sky * 0.5)
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
		
		Field last_state:States

		Field pixel_shaders:List <PostEffectPlus>

		Field grey:GreyscaleEffect
		Field speccy:SpeccyEffect

		Field main_mixer:Mixer
	
		Field test_img:Image
		Field test_cnv:Canvas

		Field gem_map_visible:Bool = True
		
End
