
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class GameMenu

	Private

		Global LastTimeScale:Float
	
	Public

		Function Control ()
	
			If Keyboard.KeyHit (Key.Escape)
				GameState.SetCurrentState (States.Exiting)
			Endif
	
			If Keyboard.KeyHit (Key.P)
			
				Select GameState.GetCurrentState ()
				
					Case States.Playing
						GameState.SetCurrentState (States.Paused)
					
					Case States.Paused
						GameState.SetCurrentState (States.Playing)
						
				End
				
			Endif
		
			' TEMP
			
			If Keyboard.KeyHit (Key.R) Or (Game.Player.TMP_Joy And Game.Player.TMP_Joy.Attached And Game.Player.TMP_Joy.ButtonPressed (7))
				Game.TMP_ResetLevel ()
			Endif
	
			Temp.Controls ()				' Debug/temp controls in Temp class
			
		End

End
