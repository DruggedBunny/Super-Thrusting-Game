
Class GameController

	Method ProcessGame ()

		GameMenu.Control ()									' Application controls (Esc to quit, etc)

		Game.CurrentLevel.Update ()
		
		Select GameState.GetCurrentState ()

			' -----------------------------------------------------------------
			Case States.Playing
			' -----------------------------------------------------------------

'				If Not Game.CurrentLevel.ExitPortal.FlythroughComplete () And Game.Player.CurrentOrb And Game.CurrentLevel.ExitPortal.PortalState = Portal.PORTAL_STATE_CLOSED
'					Print "Opening portal..."
'					Game.CurrentLevel.ExitPortal.PortalState = Portal.PORTAL_STATE_OPENING
'				Endif
				
'				If Game.CurrentLevel.ExitPortal.FlythroughComplete () And Game.CurrentLevel.ExitPortal.PortalState <> Game.CurrentLevel.ExitPortal.PORTAL_STATE_CLOSING
'					Print "Closing portal..."
'					Game.CurrentLevel.ExitPortal.PortalState = Portal.PORTAL_STATE_CLOSING
'					Game.GameState.SetCurrentState (States.LevelTween) ' TODO: See Case Portal.PORTAL_STATE_CLOSING
'				Endif
				


				If Game.Player.Alive
					Game.Player.Control		()				' Rocket controls
					Game.MainCamera.Update	(Game.Player)	' Update camera, follow player
				Else
					GameState.SetCurrentState (States.PlayEnding)
				Endif

			' -----------------------------------------------------------------
			Case States.PlayStarting
			' -----------------------------------------------------------------

				Game.Player.Control		()					' Rocket controls
				Game.MainCamera.Update	(Game.Player)		' Update camera, follow player

				' Change to Playing state after HUD has faded-in...
				
				If HUD.FadeIn () = 0.0
					GameState.SetCurrentState (States.Playing)
				Endif

			' -----------------------------------------------------------------
			Case States.PlayEnding ' Player dead...
			' -----------------------------------------------------------------
				
				Game.MainCamera.Update	(Game.Player)		' Update camera, follow player
				
				' Reset after HUD has faded out...
				
				If HUD.FadeOut () >= 1.0
					Game.ResetLevel ()
				Endif

			' -----------------------------------------------------------------
			Case States.LevelTween ' Level complete, loading new level...
			' -----------------------------------------------------------------
				
				Game.MainCamera.Update	(Game.Player)		' Update camera, follow player
				
				' Reset after HUD has faded out...

				If HUD.FadeOut (0.01) >= 1.0
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
