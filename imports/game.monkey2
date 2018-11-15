
' TEMP
Class PhysObj

End

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
		
		Global PhysStack:Stack <RigidBody>
		
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
			
			HUD = New HUDOverlay
				
			Controller.ResetLevel ()
			
		End

#If __TARGET__ <> "emscripten"
		Property VR_Renderer:VRRenderer ()
			Return vr_renderer
			Setter (renderer:VRRenderer)
				vr_renderer = renderer
		End
#Endif

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
			
			
			' TMP
			
			PhysStack = New Stack <RigidBody>
			
			
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
			Wall.		InitSound ()
			Portal.		InitSound ()
			SpaceGem.	InitSound ()
			
			' ----------------------------------------------------------------
			' Init game state...
			' ----------------------------------------------------------------

			game_state				= New GameState ' Can't be a property due to Getter/Setter weirdness

			last_state				= game_state.GetCurrentState ()

			' ----------------------------------------------------------------
			' Main control loop setup...
			' ----------------------------------------------------------------

			game_controller			= New GameController

			' ----------------------------------------------------------------
			' Scene, terrain and level setup...
			' ----------------------------------------------------------------
			
			Controller.InitScene ()

			TerrainSeed				= 0		' Random terrain: Int (RndULong ())
			TerrainSize				= 512.0	' Size of terrain cube sides
			
			Controller.SpawnLevel ()
			
'			' ----------------------------------------------------------------
'			' TMP: Clouds. TODO: Move into Cloud class!
'			' ----------------------------------------------------------------
'
			For Local loop:Int = 1 To 25
				Local c:Cloud = New Cloud (Rnd (-TerrainSize * 4.0, TerrainSize * 4.0), Rnd (TerrainSize, TerrainSize * 4.0), Rnd (-TerrainSize * 4.0, TerrainSize * 4.0), Rnd (TerrainSize * 0.5, TerrainSize))
			Next
			
			' ----------------------------------------------------------------
			' Hide mouse pointer...
			' ----------------------------------------------------------------

			Mouse.PointerVisible	= False
	
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
	
#If __TARGET__ <> "emscripten"
		Field vr_renderer:VRRenderer ' VR renderer
#Endif

		Field last_state:States

		Field pixel_shaders:List <PostEffectPlus>

		Field grey:GreyscaleEffect
		Field speccy:SpeccyEffect
		Field mono:MonoEffect

		Field main_mixer:Mixer
	
		Field delta_timer:DeltaTimer
		
		Field hud:HUDOverlay
		
End
