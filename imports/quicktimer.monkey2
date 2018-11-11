
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class QuickTimer

	Global Ticks:Long
	
	Const MICROS:Double	= 1
	Const MILLIS:Double	= 2
	Const SECS:Double	= 3
	
	Function Start ()
		Ticks = Microsecs ()
	End
	
	Function Stop (measure:Double = QuickTimer.MILLIS)
		
		Local time:Long = Microsecs () - Ticks
		
		Select measure

			Case QuickTimer.MILLIS
				Print "QuickTimer (ms): " + (1000.0 * (1.0 / 1000000.0) * time)
		
			Case QuickTimer.MICROS
				Print "QuickTimer (µs): " + time
			
			Case QuickTimer.SECS
				Print "QuickTimer (s): " + ((1.0 / 1000000.0) * time)
			
		End
		
	End
	
End
