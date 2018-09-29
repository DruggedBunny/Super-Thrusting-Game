
Class Temp

	Function Controls ()

		If Keyboard.KeyHit (Key.F)
			Game.MainMixer.PrintFaders ()
		Endif
		
		' C to complete level...
		
		If Keyboard.KeyHit (Key.C)
			Game.CurrentLevel.ExitPortal.PortalState = Portal.PORTAL_STATE_CLOSING
			Game.GameState.SetCurrentState (States.LevelTween)
		Endif
		
		' Halve fuel
		
		If Game.Player.Alive And Keyboard.KeyHit (Key.H)
			Game.Player.Fuel = Game.Player.Fuel * 0.5
		Endif

		If Keyboard.KeyHit (Key.E)
			PrintEntities ()
		Endif
		
	End
	
End

#Rem
		
		Function ReadLevelData:String (file_data:String, data_field:String)
		
			' Return string...
			
			Local data_value:String
			
			' Split into array of lines via newline...
			
			Local data_elements:String [] = file_data.Split ("~n")
			
			' Iterate each line...
			
			For Local element:String = Eachin data_elements

				' Strip outer whitespace...
				
				element = element.Trim ()
				
				' Examples:
				
				' HEIGHTFIELD	example.png	-- TAB
				' HEIGHTFIELD example.png	-- SPACE
				
				' Find first tab or space...
				
				Local tab:Int = element.Find ("~t", 0)
				If tab = -1 Then tab = element.Find (" ", 0)
				
				' No tab/space, but there is something...
				
				If element And (tab = -1)
					tab = element.Length	' Mmm, fudgy...
				Endif
				
				If data_field = element.Left (tab)
			
					' element.Slice (tab) results in "	example_data",
					' so strip outer whitespace from result...
					
					Local value:String = element.Slice (tab).Trim ()
					
					Select element.Left (tab)
					
						' Strings...
						
						Case "LEVEL_NAME"
							
							data_value = value
							Exit

						Case "LEVEL_DATA"
							
							data_value = "asset::levels/" + StripExt (LevelFile) + "/" + value
							Exit
							
						' Floats...
							
						Case	"SUN_X", "SUN_Y", "SUN_Z", "SUN_RANGE",			' Sun position/range
								"TERRAIN_HEIGHT"								' Terrain height

							data_value = value
							Exit
						
						' Ints...
						
						Case	"TERRAIN_RED_0", "TERRAIN_GREEN_0", "TERRAIN_BLUE_0",	' Terrain colour 0
								"TERRAIN_RED_1", "TERRAIN_GREEN_1", "TERRAIN_BLUE_1"	' Terrain colour 1
							
							If Int (value) < 0 Or Int (value) > 255 Then Exit
							
							' Convert RGB 0-255 values to floats...
							
							data_value = TransformRange (Int (value), 0, 255, 0.0, 1.0)
							Exit
						
						Default
							Print "Uhhh..."
							
					End
				
				Endif

			Next
			
			If data_value = "" Then Abort ("ReadLevelData: Return data_value for " + Quoted (data_field) + " is empty; check level file exists and data_field is valid...")
			
			Return data_value
			
		End

#End
