
Class DeltaTimer

	Field delta:Float

	Method New (fps:Float)
	End
	
	Method Update ()
		If GameState.GetCurrentState () <> States.Paused
			delta = App.FPS / Game.GameScene.UpdateRate
		Endif
	End
	
End
