
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' Generic stack copy function...

Function CopyStack<T>:Stack <T> (stack:Stack <T>)

	Local stack_copy:Stack <T> = New Stack <T>

	For Local f:T = Eachin stack
		stack_copy.Add (f)
	next
	
	Return stack_copy
	
End

' -----------------------------------------------------------------------------
'	Fader class: Individual fader, affected by mixer's master volume
' -----------------------------------------------------------------------------

'			1.0
'
'			+
'
'			|
'			O		<--- volume level
'			|
'			|
'			|
'			|
'			|
'
'			-
'
'			0.0

' -----------------------------------------------------------------------------
'		Mixer class: Strip of faders, plus		master volume control
' -----------------------------------------------------------------------------

'		| | O O O | | | | | O O					|
'		| | | | | O | | | | | |					|
'		O | | | | | | | | | | |					O		<--- All faders affected by this
'		| | | | | | | | | | | |					|
'		| O | | | | | | | | | |					|
'		| | | | | | | | | O | |					|
'		| | | | | | O O O | | |					|

Class Mixer
	
	Public
		
		' New sets up fader stack. Use Faders property to access this (eg. my_mixer.Faders)...
		
		Method New ()
			faders = New Stack <Fader>
		End
		
		' Add a new fader to mixer...
		
		Method AddFader:Fader (in_name:String, in_channel:Channel)
		
			Local f:Fader = New Fader (in_name, in_channel)
			
				f.ParentMixer	= Self

				f.Channel		= in_channel
				f.Level			= in_channel.Volume
				f.Name			= in_name

				f.Paused		= in_channel.Paused
				
			Faders.Add (f)
			
			Return f
						
		End

		' Called per update to remove faders that are on delayed removal.
		' (Faders can be optionally deleted when done playing.)
		
		Method UpdateFaders ()
		
			For Local f:Fader = Eachin Faders
				f.Update ()
			Next
			
		End

		' Remove individual fader. Recommend assigning the Null return value to
		' your local handle, eg.
		
		'		my_fader = my_mixer.RemoveFader (my_fader)...
		
		Method RemoveFader:Fader (f:Fader, delay_removal:Bool = False)
			f?.Remove (delay_removal) ' Now handled by Fader.Update
			Return Null
		End

		Method RemoveFader:Fader (f:Fader, fadeout:Float = 1.0)
			f?.Remove (fadeout) ' Now handled by Fader.Update
			Return Null
		End

		Method RemoveAllFaders (fadeout:Float)
		
			' Can't modify stack while iterating, so copy it...
			
			Local FadersCopy:Stack <Fader> = CopyStack (Faders)
			
			For Local f:Fader = Eachin FadersCopy
				RemoveFader (f, fadeout)
			Next
			
		End
		
		Method RemoveAllFaders (delay_removal:Bool = False)
		
			' Can't modify stack while iterating, so copy it...
			
			Local FadersCopy:Stack <Fader> = CopyStack (Faders)
			
			For Local f:Fader = Eachin FadersCopy
				RemoveFader (f, delay_removal)
			Next
			
		End
		
		' Set Paused = True to pause all channels; Paused = False to un-pause.
		
		' NB. Restores individual faders' pause status when un-pausing. (Those already
		' individually-paused will return to that state, rather than being un-paused.)
		
		Property Paused:Bool ()
		
			Return paused

			Setter (state:Bool)

				' Setter toggles pause status of all channels...
		
				paused = state
				
				For Local f:Fader = Eachin faders
	
					If paused
					
						' Pausing...
						
						f.StorePausedStatus ()	' Store fader's current status
						
						' Nasty workaround: can only pause individual faders if mixer is NOT paused:
						
						paused			= False		' Pretend mixer is not paused
						
							f.Paused	= True		' Pause fader
							
						paused			= True		' Put mixer pause status back
						
					Else
					
						' Un-pausing...
						
						f.RestorePausedStatus ()
						
					Endif
	
	
				Next

		End
		
		' Row of Faders...
		
		Property Faders:Stack <Fader> ()
			Return faders
		End

		' Master volume control (affects all channels)...
		
		Property Level:Float ()
			
			Return MasterVolume
			
			Setter (new_volume:Float)

				MasterVolume = Clamp (new_volume, 0.0, 1.0)

				For Local f:Fader = Eachin faders
					f.Mix ()
				Next

		End

		Method PrintFaders ()

			Print ""
			Print "Mixer channels:"
			Print ""

			For Local f:Fader = Eachin faders
				Print "~tMixer channel: " + f.Name
			Next
			
		End
		
	Private
	
		Global MasterVolume:Float = 1.0
		
		Field faders:Stack <Fader>
		Field paused:Bool = False
		
		' Internal stack hackery, removes redundant faders from mixer stack...
		
		Method RemoveFromStack (f:Fader)

			Local iterator:Stack <Fader>.Iterator
			
			iterator = Faders.All ()
			
			While Not iterator.AtEnd
			
				If iterator.Current = f
					iterator.Erase ()
					Continue			' Go back around loop, avoiding interator.Bump (not to be called after Erase)...
				Endif
				
				iterator.Bump ()
				
			Wend
			
		End
		
End

Class Fader

	Public
	
		Method New (in_name:String, in_channel:Channel)
		
			name	= in_name
			channel	= in_channel
			
		End
		
		' Volume level for this channel...
		
		Property Level:Float ()
			Return level
			Setter (in_level:Float)
				level = Clamp (in_level, 0.0, 1.0)
				Mix ()
		End
	
		' Real mojo Channel...
		
		Property Channel:Channel ()
			Return channel
			Setter (in_channel:Channel)
				channel = in_channel
		End
		
		' Parent Mixer...
		
		Property ParentMixer:Mixer ()
			Return mixer
			Setter (new_mixer:Mixer)
				mixer = new_mixer
		End
		
		Property Paused:Bool ()

			' User may have manually changed channel status...
			
			If paused <> Channel?.Paused
				paused = Channel?.Paused
			Endif

			Return paused

			Setter (status:Bool)
			
				If Not ParentMixer?.Paused
					Channel?.Paused	= status
					paused			= status
				Endif
				
		End
		
		' Channel display name...
		
		Property Name:String ()
			Return name
			Setter (new_name:String)
				name = new_name
		End
		
		Method StorePausedStatus ()
			paused_status_store = Paused
		End

		Method RestorePausedStatus ()
			Paused = paused_status_store
		End

	Private
	
		Field paused_status_store:Bool
		
		' Internal only: applies main mixer volume to channel...
		
		Method Mix ()
			channel.Volume = level * mixer.Level
		End

		Method Update ()
			
			If remove_when_played
			
				If Not Channel.Playing
					Remove ()
				Endif
			
			Else
			
				If fading

					Level = Level - (fadeout * Game.Delta)
				
					If Level <= 0.0
		
						' Remove...
						
						Channel?.Stop ()
						Channel = Null
						
						ParentMixer?.RemoveFromStack (Self)
						
					Endif

				Endif
			
			Endif
			
		End

		Method Remove (fade:Float)
			fading = True
			fadeout = fade
		End
		
		Method Remove (delay_removal:Bool = False)
		
'			Print "Removing " + Name + " with delay = " + delay_removal
			
			If delay_removal
				
				' Allow to finish playing...
				
				remove_when_played = True
				
			Else
			
				' Remove...
				
				Channel?.Stop ()
				Channel = Null
				
'				Print "Removing " + Name
				ParentMixer?.RemoveFromStack (Self)
'				Print "Removed " + Name
'				Print ""
				
			Endif
			
		End
		
		Field mixer:Mixer
		
		Field level:Float
		Field channel:Channel
		
		Field paused:Bool
		Field name:String
		
		Field fading:Bool
		Field fadeout:Float
		
		Field remove_when_played:Bool
		
End
