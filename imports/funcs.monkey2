
Function TimePad:String (number:String)
	
	' 0 -> 00
	' 1 -> 01
	' etc...
	
	While number.Length < 2
		number = "0" + number
	Wend
	
	Return number
	
End

Function IsPow2:Long (value:Long)
	Return Not (value & (value - 1)) ' Caveat: 0 is not Pow2! https://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
End

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

Function CountEntities:Int (entity:Entity = Null, depth:Int = 0)
	
	Local scene:Scene = Scene.GetCurrent ()

		Assert (scene, "CountEntities: No current scene!")

	Local branch:Entity[]
	
	If Not entity
		branch = scene.GetRootEntities ()
	Else
		branch = entity.Children
	Endif
	
	Local count:Int = branch.Length
	
	For Local e:Entity = Eachin branch
		count = count + CountEntities (e, depth + 1)
	Next
	
	Return count
	
End

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

Function Degrees:Float (radian:Float)
	Return radian * RadDivider
End

Function Abort (msg:String)
	Notify ("Fatal error in " + AppName, msg, True)
	App.Terminate ()
End

Function TransformRange:Float (input_value:Float, from_min:Float, from_max:Float, to_min:Float, to_max:Float)

	' Algorithm via jerryjvl at https://stackoverflow.com/questions/929103/convert-a-number-range-to-another-range-maintaining-ratio
	
	Local from_delta:Float	= from_max	- from_min	' Input range,	eg. 0.0 - 1.0
	Local to_delta:Float	= to_max	- to_min	' Output range,	eg. 5.0 - 10.0
	
	Assert (from_delta <> 0.0, "TransformRange: Invalid input range!")
	
	Return (((input_value - from_min) * to_delta) / from_delta) + to_min
	
End

Function Blend:Float (in:Float, target:Float, delta:Float = 0.1)
	If Abs (target - in) < Abs (delta) Then Return target
	Return in + ((target - in) * delta)
End

Function Quoted:String (msg:String)
	Return "~q" + msg + "~q"
End

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

Function ValidateJoystick:Joystick (j:Joystick)

	If Not j Or Not j.Attached
		j = FindFirstXboxPad ()
	Endif
	
	Return j
	
End

Function ReplaceAssetPath:String (path:String)

	If path.ToLower ().Left (7) = "asset::"
		
		path = path.Slice (7)
	
	Endif
	
	Return path
	
End

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

Function ShadowText:Void (canvas:Canvas, s:String, x:Float, y:Float, fore:Color = Null, back:Color = Null)
	If Not fore Then fore = Color.White
	If Not back Then back = Color.Black
	canvas.Color = back
	canvas.DrawText	(s, x + 1, y + 1)
	canvas.Color = fore
	canvas.DrawText	(s, x, y)
End

Function CheckerPixmap:Pixmap (color0:Color = Color.Black, color1:Color = Color.White)
 
	Local pixels:Pixmap = New Pixmap (256, 256, PixelFormat.RGBA8)
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

Function ModelFromTriangle:Model (in_model:Model, index:UInt, mat_index:Int)

	Local tri_model:Model = New Model

		Assert (mat_index < in_model.Mesh.NumMaterials, "Material index too high")
		Assert (index + 2 < in_model.Mesh.NumIndices, "Index too high") ' Think that's right...
				
		tri_model.Material			= in_model.Materials [mat_index]
		tri_model.Material.CullMode	= CullMode.None

		tri_model.Name = "Triangle created at " + Millisecs ()
		
	Local indices:UInt []		= in_model.Mesh.GetIndices (mat_index)

	Local tri_verts:Vertex3f []	= New Vertex3f [3]
	
		' mesh-local co-ords...
		
		tri_verts [0]	= in_model.Mesh.GetVertex (indices [index + 0])
		tri_verts [1]	= in_model.Mesh.GetVertex (indices [index + 1])
		tri_verts [2]	= in_model.Mesh.GetVertex (indices [index + 2])
	
	Local tri_indices:UInt [] = New UInt [3]
	
		tri_indices [0]	= 0
		tri_indices [1]	= 1
		tri_indices [2]	= 2
	
	Local tri_mesh:Mesh	= New Mesh (tri_verts, tri_indices)
	
		tri_mesh.UpdateNormals ()
		tri_mesh.UpdateTangents ()
 
		tri_model.Mesh		= tri_mesh
 		tri_model.Parent	= in_model
 		
	Return tri_model
 
End

Global Game:GameWindow

Function Run3D (title:String, width:Int, height:Int, flags:WindowFlags = WindowFlags.Center)

	New AppInstance

	If Not width Or Not height
		width	= App.DesktopSize.X
		height	= App.DesktopSize.Y
	Endif
	
	Game = New GameWindow (title, width, height, flags)

	App.Run ()

End
