
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' Collection of non game-specific functions.

' PadDigit: Used here to pad individual time elements (hour, min, sec) to
' show in 00:00:00 format.

Function PadDigit:String (number:String, pad:Int)
	
	' 0 -> 00
	' 1 -> 01
	' etc...
	
	While number.Length < pad
		number = "0" + number
	Wend
	
	Return number
	
End

' IsPow2: Returns True if number is a power of 2.

Function IsPow2:Long (value:Long)
	Return Not (value & (value - 1)) ' Caveat: 0 is not Pow2! https://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
End

' CountEntities: Returns number of entities in scene, or number of child entities if entity is passed in.

Function CountEntities:Int (entity:Entity = Null)
	
	Local scene:Scene = Scene.GetCurrent ()

		Assert (scene, "CountEntities: No current scene!")

	Local branch:Entity []
	
	If Not entity
		branch = scene.GetRootEntities ()
	Else
		branch = entity.Children
	Endif
	
	Local count:Int = branch.Length
	
	For Local e:Entity = Eachin branch
		count = count + CountEntities (e)
	Next
	
	Return count
	
End

' FindEntityFromRigidBody: Returns entity with the attached RigidBody rb, or Null.

' WTFingF? Works for RocketParticle but not ExplosionParticle???

Function FindEntityFromRigidBody:Entity (rb:RigidBody, entity:Entity = Null)
	
	Local scene:Scene = Scene.GetCurrent ()

		Assert (scene, "FindEntityFromRigidBody: No current scene!")

	Local branch:Entity []
	
	If Not entity
		branch = scene.GetRootEntities ()
	Else
		branch = entity.Children
	Endif
	
	Local found_entity:Entity
	
	Local count:Int = branch.Length
	
	For Local e:Entity = Eachin branch
	
		found_entity = Null
		
		If e.GetComponent <RigidBody> () = rb
			found_entity = e
			Exit
		Endif
		
		FindEntityFromRigidBody (rb, e)

	Next
	
	Return found_entity
	
End

' PrintEntities: Prints a tree-view of entities in scene to the console, or children of an entity if passed in.

' IMPORTANT: Don't use depth parameter! This is used by the function to determine level of recursion!

Function PrintEntities:Int (e:Entity = Null, depth:Int = 0)
	
	Local scene:Scene = Scene.GetCurrent ()
	
		Assert (scene, "PrintEntities: No current scene!")
	
	Local branch:Entity[]
	
	If Not e
		branch = scene.GetRootEntities ()
		Print ""
		Print "o Scene Root"
	Else
		branch = e.Children
	Endif
	
	Local tabs:String
	
	For Local tab:Int = 1 To depth + 1
		tabs = tabs + "    "
	Next
	
	Local count:Int = branch.Length
	
	For Local e:Entity = Eachin branch
		Print tabs + "o " + e.Name
		count = count + PrintEntities (e, depth + 1)
	Next
	
	If Not e Then Print ""
	
	Return count
	
End

' Degrees: Converts radians to degrees; needed by some mojo/mojo3d functions if
' you don't think in radians or value your sanity!

Function Degrees:Float (radians:Float)
	Return radians * RAD_DIVIDER
End

' Abort: Terminates app with error message passed in.

Function Abort (msg:String)
#If __TARGET__ <> "emscripten"
	Notify ("Fatal error in " + AppName, msg, True)
#Else
	Print "*** Fatal error in " + AppName + ": " + msg
#Endif
	App.Terminate ()
End

' TransformRange: Incredibly useful for warping a value from one range of values into another
' range, eg. from 0-255 into 0.0-1.0, where a value of 127 would be transformed to (approx?) 0.5.

' Search source for TransformRange to see wide range of uses!

Function TransformRange:Float (input_value:Float, from_min:Float, from_max:Float, to_min:Float, to_max:Float)

	' Algorithm via jerryjvl at https://stackoverflow.com/questions/929103/convert-a-number-range-to-another-range-maintaining-ratio
	
	Local from_delta:Float	= from_max	- from_min	' Input range,	eg. 0.0 - 1.0
	Local to_delta:Float	= to_max	- to_min	' Output range,	eg. 5.0 - 10.0
	
	Assert (from_delta <> 0.0, "TransformRange: Invalid input range!")
	
	Return (((input_value - from_min) * to_delta) / from_delta) + to_min
	
End

' Blend: Blends between input value and target value by delta value.

Function Blend:Float (in:Float, target:Float, delta:Float = 0.1)
	If Abs (target - in) < Abs (delta) Then Return target
	Return in + ((target - in) * delta)
End

Function FrameStretch:Float (value:Float, elapsed_time:Float, intended_time:Float = (1.0 / Game.GameScene.UpdateRate))

	If intended_time = 0.0 Then Return value ' Avoid divide by zero!
	
	'Print timescale
	'Print elapsed
	'Print elapsed / timescale
	'Print timescale / elapsed
	'Print ""
	
	Return value * (elapsed_time / intended_time)
	
End
		
' Quoted: Adds quotes around string.

Function Quoted:String (msg:String)
	Return "~q" + msg + "~q"
End

' Iterates through gamepads/sticks to find first attached Xbox pad in list.

Function FindFirstXboxPad:Joystick ()

	' Try find an Xbox gamepad, use first one found...
	
	Local j:Joystick
	
	For Local loop:Int = 0 Until Joystick.NumJoysticks ()

		j = Joystick.Open (loop)

		If j

			If Not j.Name.StartsWith ("XInput Controller #")
				j.Close ()
				j = Null
			Else
				Exit ' Found one!
			Endif

		Endif
		
	Next

	Return j
	
End

' ValidateJoystick: Tries to re-attach gamepad to game if lost. Handles
' gamepad battery outages, removal from computer, etc.

Function ValidateJoystick:Joystick (j:Joystick)

	If Not j Or Not j.Attached
		j = FindFirstXboxPad ()
	Endif
	
	Return j
	
End

' PixmapFormat: Returns pixel format as a string.

Function PixmapFormat:String (pixmap:Pixmap)

	Select pixmap.Format
		Case PixelFormat.Unknown
			Return "PixelFormat.Unknown"
		Case PixelFormat.Depth16
			Return "PixelFormat.Depth16"
		Case PixelFormat.Depth24
			Return "PixelFormat.Depth24"
		Case PixelFormat.Depth32
			Return "PixelFormat.Depth32"
		Case PixelFormat.IA16
			Return "PixelFormat.IA16"
		Case PixelFormat.RGB24
			Return "PixelFormat.RGB24"
		Case PixelFormat.RGBA32F
			Return "PixelFormat.RGBA32F"
		Case PixelFormat.RGBA16F
			Return "PixelFormat.RGBA16F"
		Case PixelFormat.I8
			Return "PixelFormat.I8"
		Case PixelFormat.A8
			Return "PixelFormat.A8"
		Case PixelFormat.IA8
			Return "PixelFormat.IA8"
		Case PixelFormat.RGB8
			Return "PixelFormat.RGB8"
		Case PixelFormat.RGBA8
			Return "PixelFormat.RGBA8"
		Case PixelFormat.RGBA32
			Return "PixelFormat.RGBA32"
	End

	Return ""

End

' ShadowText: Used in HUD to draw text with shadow, to enhance readability.

Function ShadowText:Void (canvas:Canvas, s:String, x:Float, y:Float, fore:Color = Null, back:Color = Null)

	If Not fore Then fore = Color.White
	If Not back Then back = Color.Black

	canvas.Color = back
	canvas.DrawText	(s, x + 1, y + 1)

	canvas.Color = fore
	canvas.DrawText	(s, x, y)

End

' CheckerPixmap: Creates a checkerboard pixmap from two colours. Used for terrain textures here.

Function CheckerPixmap:Pixmap (width:Int, height:Int, color0:Color = Color.Black, color1:Color = Color.White)
 
	Local pixels:Pixmap = New Pixmap (width, height, PixelFormat.RGBA8)
	
	pixels.Clear (color0)
	
	Local pixel_toggle:Bool = False
	
	For Local gp_y:Int = 0 Until pixels.Height
		For Local gp_x:Int = 0 Until pixels.Width
			If pixel_toggle Then pixels.SetPixel (gp_x, gp_y, color1)
			pixel_toggle = Not pixel_toggle
		Next
		pixel_toggle = Not pixel_toggle
	Next
	
	Return pixels
	
End

' ModelFromTriangle: Possibly no longer relevant, but generates a separate
' triangle model from a model's specified triangle.

' See ModelFromTriangles, below!

Function ModelFromTriangle:Model (in_model:Model, index:UInt, mat_index:Int)

	Local tri_model:Model			= New Model

		Assert (mat_index < in_model.Mesh.NumMaterials, "Material index too high")
		Assert (index + 2 < in_model.Mesh.NumIndices, "Index too high") ' Think that's right...
		
		tri_model.Material			= in_model.Materials [mat_index]
		tri_model.Material.CullMode	= CullMode.None

		'tri_model.Name = "Triangle created at " + Millisecs ()
		
	Local indices:UInt []			= in_model.Mesh.GetIndices (mat_index)

	Local tri_verts:Vertex3f []		= New Vertex3f [3]
	
		' mesh-local co-ords...
		
		tri_verts [0]				= in_model.Mesh.GetVertex (indices [index + 0])
		tri_verts [1]				= in_model.Mesh.GetVertex (indices [index + 1])
		tri_verts [2]				= in_model.Mesh.GetVertex (indices [index + 2])
	
	Local tri_indices:UInt []		= New UInt [3]
	
		tri_indices [0]				= 0
		tri_indices [1]				= 1
		tri_indices [2]				= 2
	
	Local tri_mesh:Mesh				= New Mesh (tri_verts, tri_indices)
	
		' Appears to make no visible difference for a single tri...
		
'		tri_mesh.UpdateNormals ()
'		tri_mesh.UpdateTangents ()
 
		tri_model.Mesh				= tri_mesh
 		tri_model.Parent			= in_model
 		
	Return tri_model
 
End

' ModelFromTriangles: Generates a separate model from a range of existing model triangles.
' Used for chunky explosions via PhysicsTri class!

Function ModelFromTriangles:Model (in_model:Model, index_start:UInt, tri_count:UInt, mat_index:Int)

' TODO: index_start = tri number??

'Print "MODEL: " + (in_model.Mesh.NumIndices / 3)

	' WIP: Start again! Trying to get bigger chunks at a time...
	
	Local tri_model:Model				= New Model

		Assert (mat_index < in_model.Mesh.NumMaterials, "Material index too high")
		Assert (index_start + 2 < in_model.Mesh.NumIndices, "Index too high")			' Think that's right...
		
'		Local black_mat:PbrMaterial		= New PbrMaterial (Color.Black)
		
'		Select Int (Rnd (5)) ' 0 - 4
'			Case 0, 1, 2, 3
'				tri_model.Material		= black_mat
'			Default
'				tri_model.Material		= in_model.Materials [mat_index]
'		End

		tri_model.Material				= in_model.Materials [mat_index]
		
			If tri_count = 1
				tri_model.Material.CullMode	= CullMode.None
			Endif

		'tri_model.Name = "Triangle created at " + Millisecs ()
	
	' Model's triangle indices...
	
	Local indices:UInt []				= in_model.Mesh.GetIndices (mat_index)

	Local index_count:UInt				= tri_count * 3
	Local index_end:UInt				= index_start + index_count
	
	' New triangle's indices/vertices...
	
	Local tri_indices:UInt []			= New UInt		[index_count]
	Local tri_verts:Vertex3f []			= New Vertex3f	[index_count]
	
	If index_end > indices.Length
		index_end = indices.Length
	Endif	
			
	For Local tri_index:UInt = index_start Until index_end Step 3

		If tri_index >= indices.Length Then Exit
		
		tri_verts [tri_index - index_start]			= in_model.Mesh.GetVertex (indices [tri_index])
		tri_verts [(tri_index - index_start) + 1]	= in_model.Mesh.GetVertex (indices [tri_index + 1])
		tri_verts [(tri_index - index_start) + 2]	= in_model.Mesh.GetVertex (indices [tri_index + 2])

		tri_indices [tri_index - index_start]		= tri_index - index_start
		tri_indices [(tri_index - index_start) + 1]	= (tri_index - index_start) + 1
		tri_indices [(tri_index - index_start) + 2]	= (tri_index - index_start) + 2

	Next
		
	Local tri_mesh:Mesh				= New Mesh (tri_verts, tri_indices)
	
		' This appears to make no visible difference for a single tri:
		
'		tri_mesh.UpdateNormals ()
'		tri_mesh.UpdateTangents ()

		tri_model.Mesh				= tri_mesh
 		tri_model.Parent			= in_model
 		
	Return tri_model
 
End

Function ExplodeModel (model:Model, body:RigidBody, tris_per_chunk:UInt = 0, explosion_particles:Int = 500)

	QuickTimer.Start ()

	Local particle_vel:Float = 0.75

	For Local particles:Int = 0 Until explosion_particles

		' Create angle for particle...
		
		Local angle:Vec3f = model.Basis * New Vec3f (
		
							Rnd (-particle_vel, particle_vel),
							Rnd (-particle_vel, particle_vel),
							Rnd (-particle_vel, particle_vel))			.Normalize () * Rnd (particle_vel)

		' Create particle...
		
		ExplosionParticle.Create	(	model,		' Rocket
										angle,				' 3D angle
										Rnd (0.1, 1.0),		' Size
										0.99)				' Fadeout-multiplier
	Next
	
	For Local mat:Int = 0 Until model.Mesh.NumMaterials
	
		' TESTING...
		
		Local mat_tris:UInt = model.Mesh.GetIndices (mat).Length / 3
		
		If Not tris_per_chunk Then tris_per_chunk = Max (12, Int (Rnd (mat_tris)))

		' Going through triangles of each material in turn...
		
		Local steps:UInt = 3 * tris_per_chunk * TRI_SKIPPER ' TRI_SKIPPER set in consts.monkey2
		
		For Local tri:UInt = 0 Until model.Mesh.GetIndices (mat).Length Step steps
		
			Local tri_model:Model		= ModelFromTriangles (model, tri, tris_per_chunk, mat)
			
				tri_model.Parent		= Null
				tri_model.CastsShadow	= False

			Local ptri:PhysicsTri		= New PhysicsTri (tri_model) ' Note to self: Not a 'tri' here, but a chunk!

				ptri.SrcBody			= body
				
				If model = Game.Player.RocketModel
					ptri.FromRocket		= True
				Endif
				
		Next
	
	Next

	QuickTimer.Stop ()

End
		
' Run3D: Just simplifies application setup code.

Function Run3D (title:String, width:Int, height:Int, flags:WindowFlags = WindowFlags.Center)

	New AppInstance

	If Not width Or Not height
		width	= App.DesktopSize.X
		height	= App.DesktopSize.Y
	Endif
	
	Game = New GameWindow (title, width, height, flags)

	App.Run ()

End

' LonePixel: Probably no longer used, but tests if a given pixel is bordered by any
' pixels of same colour. If not, returns True to reflect a lone pixel. May need again!

Function LonePixel:Bool (x:Int, y:Int, argb:Color, pixmap:Pixmap)

	Local pix:Color = pixmap.GetPixel (x, y)
	
	If pix = argb
		
		If pixmap.GetPixel (x - 1, y) = pix Or
			pixmap.GetPixel (x, y - 1) = pix Or
				pixmap.GetPixel (x + 1, y) = pix Or
					pixmap.GetPixel (x, y + 1) = pix
			
						Return False

		Endif
		
	Endif
	
	Return True

End

Function RemoveFromStack<T>:Void (o:Object, s:Stack<T>)

	Local iterator:Stack <T>.Iterator
	
	iterator = s.All ()
	
	While Not iterator.AtEnd
	
		If iterator.Current = o
			iterator.Erase ()
			Continue			' Go back around loop, avoiding interator.Bump (not to be called after Erase)...
		Endif
		
		iterator.Bump ()
		
	Wend
	
End
