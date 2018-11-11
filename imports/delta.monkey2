
Const AVG_COUNT:Int = 60

Class DeltaTimer

	' Usage...
	
	' 1)	Create DeltaTimer object, eg.
	' 		"Local dt:DeltaTimer = New DeltaTimer (60)"
	' 		where 60 is your game's intended frame rate,
	' 		regardless of device frame rate.
	
	' 2)	Call dt.UpdateDelta at start of OnUpdate...
	
	' 3)	Multiply all speeds by dt.delta...
	
	' 4)	That's it.
	
	Field targetfps:Float = AVG_COUNT
	
	Field currentticks:Float
	Field lastticks:Float
	
	Field averages:Float []
	Field average:Float
	
	Field frametime:Float
	Field delta:Float
	
	Method New (fps:Float)
		averages = New Float [AVG_COUNT]
		targetfps = fps
		lastticks = Millisecs ()
	End
	
	Method Update ()
	
		' TODO: This is full of shit that either doesn't work or does nothing!
		
		currentticks = Millisecs ()
		frametime = currentticks - lastticks
		
		For Local loop:Int = 0 To AVG_COUNT - 2
			averages [loop] = averages [loop + 1]
			average = average + averages [loop]
		Next

		averages [AVG_COUNT - 1] = frametime

		average = average / Float (AVG_COUNT)
		
		targetfps = Game.GameScene.UpdateRate'App.FPS ' WIP
		
		delta = frametime / (1000.0 / targetfps)
		lastticks = currentticks
		
	End
	
End

'Class DeltaTimer
'
'	Field delta:Float
'
'	Method New (fps:Float)
'	End
'	
'	Method Update ()
'		If GameState.GetCurrentState () <> States.Paused
'			delta = App.FPS / Game.GameScene.UpdateRate
'		Endif
'	End
'	
'End
'