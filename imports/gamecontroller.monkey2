
Class GameController

	Field last_timescale:Float
	
	Method ProcessGame ()

		GameMenu.Control ()									' Application controls (Esc to quit, etc)

		Game.CurrentLevel.Update ()

		Game.MainMixer.UpdateFaders ()
		
		Select GameState.GetCurrentState ()

			Case States.Paused
				
'				If Game.MainMixer.MasterVolume > 0.0
'					Game.MainMixer.MasterVolume = Blend (Game.MainMixer.MasterVolume, 0.0, 0.2)
'				Endif
				
				If Not Game.MainMixer.Paused Then Game.MainMixer.Paused = True

				If Game.GameScene.World.TimeScale
					last_timescale = Game.GameScene.World.TimeScale
					Game.GameScene.World.TimeScale = 0.0
				Endif
				
			' -----------------------------------------------------------------
			Case States.Playing
			' -----------------------------------------------------------------

'				If Game.MainMixer.MasterVolume < 1.0
'					Game.MainMixer.MasterVolume = Blend (Game.MainMixer.MasterVolume, 1.0, 0.2)
'				Endif
	
				If Game.MainMixer.Paused Then Game.MainMixer.Paused = False

				If Not Game.GameScene.World.TimeScale
					Game.GameScene.World.TimeScale = last_timescale
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

				Game.GameScene.World.TimeScale = 1.0

				Game.Player.Control		()					' Rocket controls
				Game.MainCamera.Update	(Game.Player)		' Update camera, follow player

				' Change to Playing state after HUD has faded-in...
				
				If HUD.FadeIn () = 0.0
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
				
				Local hud_fade:Float = HUD.FadeOut ()
				
				If Game.GameScene.World.TimeScale > 0.25 Then Game.GameScene.World.TimeScale = Game.GameScene.World.TimeScale * 0.99
				
				If hud_fade >= 1.0
					Game.ResetLevel ()
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

				If HUD.FadeOut (rate) >= 1.0
					If Game.CurrentLevel.ExitPortal.PortalState = Portal.PORTAL_STATE_CLOSED
						Game.SpawnNextLevel ()
					Endif
				Endif

			' -----------------------------------------------------------------
			Case States.Exiting
			' -----------------------------------------------------------------
			
				Game.Player.Control		()					' Rocket controls
				Game.MainCamera.Update	(Game.Player)		' Update camera, follow player
				
				' Exit after HUD has faded out...
				
				If HUD.FadeOut (0.025) >= 1.0
					App.Terminate ()
				Endif
			
		End
		
	End
	
End
