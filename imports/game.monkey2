
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' Core application, comprised of a collection of globally-accessible properties
' and methods that are initialised here, and stuff that specifically belongs to
' the mojo Window class.

' Main functionality is handled by GameController, which is permitted to make
' changes to GameWindow stuff.

Class GameWindow Extends Window

	Public
		
		Property TerrainSeed:ULong ()
			Return terrain_seed
			Setter (seed:ULong)
				terrain_seed = seed
		End
		
		Property TerrainSize:Float ()
			Return terrain_size
			Setter (size:Float)
				terrain_size = size
		End
		
		Property Controller:GameController ()
			Return game_controller
		End
		
		Property HUD:HUDOverlay ()
			Return hud
			Setter (in_hud:HUDOverlay)
				hud = in_hud
		End
		
		Property GameTimer:DeltaTimer ()
			Return delta_timer
		End
		
		Property Delta:Float ()
			Return delta_timer.delta
		End
		
		Property PixelShaders:List <PostEffectPlus> ()
			Return pixel_shaders
			Setter (list:List <PostEffectPlus>)
				pixel_shaders = list
		End
		
		Property GreyscaleShader:PostEffectPlus ()
			Return grey
			Setter (shader:PostEffectPlus)
				grey = Cast <GreyscaleEffect> (shader)
		End

		Property SpeccyShader:PostEffectPlus ()
			Return speccy
			Setter (shader:PostEffectPlus)
				speccy = Cast <SpeccyEffect> (shader)
		End

		Property MonoShader:PostEffectPlus ()
			Return mono
			Setter (shader:PostEffectPlus)
				mono = Cast <MonoEffect> (shader)
		End

		Property MainMixer:Mixer ()
			Return main_mixer
			Setter (in_mixer:Mixer)
				main_mixer = in_mixer
		End
		
		' Temp: Used only by GameMenu.Control -> R or Gamepad Start to reset level during development!
		
		Method TMP_ResetLevel ()
			Controller.ResetLevel ()
		End
		
		Property VR_Renderer:VRRenderer ()
			Return vr_renderer
			Setter (renderer:VRRenderer)
				vr_renderer = renderer
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
			Super.New (title, width, height, flags | WindowFlags.Resizable)
		End
	
		Method OnCreateWindow () Override

			MainMixer					= New Mixer

				MainMixer.Level			= 0.0
			
			' ----------------------------------------------------------------
			' Pre-load sounds...
			' ----------------------------------------------------------------

			Orb.		InitSound ()
			DummyOrb.	InitSound ()
			Rocket.		InitSound () ' Includes pad refueling sound!
			TrumpWall.	InitSound ()
			Portal.		InitSound ()
			SpaceGem.	InitSound ()
			
			' ----------------------------------------------------------------
			' Terrain, level and scene setup...
			' ----------------------------------------------------------------
			
			TerrainSeed				= 0			' Test: Int (RndULong ())
			TerrainSize				= 1024.0	' Size of terrain cube sides
			
			CurrentLevel			= New Level (terrain_seed, terrain_size)
	
				If Not CurrentLevel Then Abort ("OnCreateWindow: Failed to create level!")

			' ----------------------------------------------------------------
			' Init gameloop...
			' ----------------------------------------------------------------

			game_controller			= New GameController

			Controller.InitScene (TerrainSize)

			' ----------------------------------------------------------------
			' Player setup...
			' ----------------------------------------------------------------

			Local rocket_pos:Vec3f	= CurrentLevel.SpawnLevel ()
			
			Player					= Controller.SpawnRocket (rocket_pos)
			
				If Not Player Then Abort ("OnCreateWindow: SpawnRocket failed to spawn rocket!")
			
			' ----------------------------------------------------------------
			' Camera setup...
			' ----------------------------------------------------------------

			MainCamera				= New GameCamera (App.ActiveWindow.Rect, MainCamera, terrain_size)
			
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
			' Init HUD...
			' ----------------------------------------------------------------

			HUD = New HUDOverlay

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
			
			delta_timer				= New DeltaTimer (GameScene.UpdateRate)
			
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
			' Effectively, run main loop, managing game state...
			' ----------------------------------------------------------------
			
			Controller.ProcessGame ()

			' ----------------------------------------------------------------
			' Render scene and overlays...
			' ----------------------------------------------------------------

			Controller.Render (canvas)

			' ----------------------------------------------------------------
			' Tell system we are ready to draw this scene frame...
			' ----------------------------------------------------------------

			RequestRender ()
	
		End

	Private

		Field game_scene:Scene
		Field current_level:Level
	 	Field main_camera:GameCamera
		Field player:Rocket
		Field game_state:GameState

		Field game_controller:GameController
		
		Field terrain_seed:ULong
		Field terrain_size:Float
		
		Field vr_renderer:VRRenderer ' VR renderer
		
		Field last_state:States

		Field pixel_shaders:List <PostEffectPlus>

		Field grey:GreyscaleEffect
		Field speccy:SpeccyEffect
		Field mono:MonoEffect

		Field main_mixer:Mixer
	
		Field delta_timer:DeltaTimer
		
		Field hud:HUDOverlay
		
End
