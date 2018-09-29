
Enum States

	Playing,		' In play
	PlayStarting,	' Starting up (fading in)
	PlayEnding,		' Player dead (fading out)
	LevelTween,		' Between levels
	StartMenu,		' Start menu options
	InGameMenu,		' In-game menu options
	Exiting,		' Exiting game
	Paused			' Paused
	
End

Class GameState

	Public
		
		Method New ()
			
			' Gah, fuck reflection!
			
			StateName = New String [8]
			
				StateName [States.Playing]		= "Playing"
				StateName [States.PlayStarting]	= "Play starting"
				StateName [States.PlayEnding]	= "Play ending"
				StateName [States.LevelTween]	= "Level tweening"
				StateName [States.StartMenu]	= "Start menu"
				StateName [States.InGameMenu]	= "In-game menu"
				StateName [States.Exiting]		= "Exiting game"
				StateName [States.Paused]		= "Paused"
			
			SetCurrentState (States.PlayStarting)
			
		End
		
		Function GetCurrentState:States ()
			Return GameState.CurrentState
		End
		
		Function SetCurrentState (new_state:States)
			If GameState.CurrentState <> States.Exiting
				GameState.CurrentState = new_state
				'Print "State: " + StateName [GameState.CurrentState]
			Endif
		End
		
	Private
		
		Global CurrentState:States
		Global StateName:String []

End
