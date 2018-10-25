
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' Yes, this is stupid! But it highlights TODOs better and prompts me to reduce clutter in Output window!

Global ToDoList:List <String> = New List <String>

Function TODO (todo:String)
	ToDoList.AddLast (todo)
End

Function ListTODOs ()

	Print ""

	For Local s:String = Eachin ToDoList
		Print "TODO: " + s
	Next

	Print ""
	
End
