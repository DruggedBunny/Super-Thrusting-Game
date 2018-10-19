
Class QuickTimer

	Global Ticks:Long
	
	Function Start ()
		Ticks = Microsecs ()
	End
	
	Function Stop ()
		Print "QuickTimer (µs): " + (Microsecs () - Ticks)
	End
	
End
