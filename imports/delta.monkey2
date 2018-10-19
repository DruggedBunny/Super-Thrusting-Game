
Class DeltaTimer

	Field delta:Float

	Method New (fps:Float)
	End
	
	Method Update ()
'		delta = Game.GameScene.UpdateRate / App.FPS
		delta = App.FPS / Game.GameScene.UpdateRate
	End
	
End
