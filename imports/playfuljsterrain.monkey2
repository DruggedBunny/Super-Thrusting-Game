
Class PlayfulJSTerrainMap
 
	' Hunter Loftis
	' http://www.playfuljs.com/realistic-terrain-in-130-lines/
	' https://github.com/hunterloftis/playfuljs-demos/blob/gh-pages/terrain/index.html
	
	Public
	
		Property Size:Float ()
			Return size
		End
		
		Method New (seed:ULong, pixmap_size:Int = 1024, in_roughness:Float = 0.5)
	 
			Assert (IsPow2 (pixmap_size), "PlayfulJSTerrain.New (pixmap_size) must be power of 2!")
			
			SeedRnd (seed)
			
			roughness = in_roughness
			size = pixmap_size + 1
			max = size - 1
			
			map = New Float[size * size]
	 
			Generate ()
			
		End
		
		Method GetHeight:Float (x:Int, y:Int)
		
			If (x < 0 Or x > max Or y < 0 Or y > max) Then Return -1
			
			Return map[x + size * y]
			
		End
		
		Method SetHeight (x:Int, y:Int, val:Float)
		
			map[x + size * y] = val
			
			If val < lower Then lower = val
			If val > upper Then upper = val
			
		End
		
		Method RenderPixmap:Pixmap (blur:Int = 0)
		
			Local pix:Pixmap = New Pixmap (max, max, PixelFormat.I8)
			
			Local rgb:Float
			Local color:Color = New Color (0.0, 0.0, 0.0)
	 
			For Local y:Int = 0 Until max
				For Local x:Int = 0 Until max
				
					If (upper - lower) = 0 ' Make sure range is valid for TransformRange!
						rgb = 0.0
					Else
						rgb = TransformRange (GetHeight (x, y), lower, upper, 0.0, 1.0)
					Endif
					
					color.R = rgb
					color.G = rgb
					color.B = rgb
					
					pix.SetPixel (x, y, color)
					
				Next
			Next
	 
	 		' GaussianBlur processes in RGBA8 format!
	 		
	 		If blur Then pix = GaussianBlur (pix, blur).Convert (PixelFormat.I8)
	 		
			Return pix
			
		End

	Private
	
		Method Generate ()
	 
	 		lower = 0
	 		upper = 0
	 		
			SetHeight (0, 0, max)
			SetHeight (max, 0, max * 0.5)
			SetHeight (max, max, 0)
			SetHeight (0, max, max * 0.5)
			
			Divide (max)
	 
		End
		
		Method Divide (size:Int)
	 
			Local half:Int = size / 2	' Weird failed optimisation: "If size < 2 Then Return" at start is slower than this with half < 1 check!
	 
			If half < 1 Then Return
			
			Local scale:Float = roughness * size
			Local scale2:Float = scale * 2 ' Quick pre-calc for the two loops below...
			
			Local x:Int
			Local y:Int
			
			For y = half To max Step size
				For x = half To max Step size
					Square (x, y, half, Rnd () * scale2 - scale)
				Next
			Next
		    
			For y = 0 To max Step half
				For x = (y + half) Mod size To max Step size
					Diamond (x, y, half, Rnd () * scale2 - scale)
				Next
			Next
	 
			' Recursive call until too small (see "If half < 1")...
			
			Divide (size / 2)
	 
		End
		  
		Method Square (x:Int, y:Int, in_size:Int, offset:Float)
	 
			Local total:Float
			Local count:Int
	
			Local xms:Int = x - in_size
			Local yms:Int = y - in_size
	 
			Local xps:Int = x + in_size
			Local yps:Int = y + in_size
			
			Local h0:Float = GetHeight (xms, yms)
			Local h1:Float = GetHeight (xps, yms)
			Local h2:Float = GetHeight (xps, yps)
			Local h3:Float = GetHeight (xms, yps)
	
			If h0 <> -1 Then total = total + h0; count = count + 1
			If h1 <> -1 Then total = total + h1; count = count + 1
			If h2 <> -1 Then total = total + h2; count = count + 1
			If h3 <> -1 Then total = total + h3; count = count + 1
				
			If Not count Then Return ' Don't divide by zero!
			
			SetHeight (x, y, total / count + offset)
	    
		End
		  
		Method Diamond (x:Int, y:Int, in_size:Int, offset:Float)
		  
			Local total:Float
			Local count:Int
			
			Local h0:Float = GetHeight (x, y - in_size)
			Local h1:Float = GetHeight (x + in_size, y)
			Local h2:Float = GetHeight (x, y + in_size)
			Local h3:Float = GetHeight (x - in_size, y)
			
			If h0 <> -1 Then total = total + h0; count = count + 1
			If h1 <> -1 Then total = total + h1; count = count + 1
			If h2 <> -1 Then total = total + h2; count = count + 1
			If h3 <> -1 Then total = total + h3; count = count + 1
	
			If Not count Then Return ' Don't divide by zero!
			
			SetHeight (x, y, total / count + offset)
		    
		End

	Private
	
		Field size:Int
		Field max:Int
		Field map:Float[]
		Field roughness:Float
		
		Field upper:Float
		Field lower:Float
 
End
