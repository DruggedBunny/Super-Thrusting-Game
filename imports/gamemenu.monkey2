
Class GameMenu

	Function Control ()

		If Keyboard.KeyHit (Key.Escape)
			GameState.SetCurrentState (States.Exiting)
		Endif

		' TEMP
		
		If Keyboard.KeyHit (Key.R) Or (Game.Player.Joy And Game.Player.Joy.Attached And Game.Player.Joy.ButtonPressed (7))
			Game.TMP_ResetLevel ()
		Endif

		Temp.Controls ()				' Debug/temp controls in Temp class
		
	End

End
