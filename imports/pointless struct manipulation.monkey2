
#Import "<std>"

Using std..

Struct Test
	Field bullets:Int
	Field mass:Float
End

Function Main ()

	Local t:Test = New Test
	
	t.bullets	= 100
	t.mass		= 1000.0
	
	Print t.bullets
	Print t.mass

	Local pointer:Void Ptr = Varptr t
	
	Print Cast <Int Ptr> (pointer)[0]
	Print Cast <Float Ptr> (pointer)[1]

	Cast <Int Ptr> (pointer)[0] = 101
	Cast <Float Ptr> (pointer)[1] = Cast <Float Ptr> (pointer)[1] - 1
	
	Print t.bullets
	Print t.mass

End
