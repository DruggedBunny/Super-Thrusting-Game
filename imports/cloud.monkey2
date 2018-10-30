
Class Cloud

	Field sprite:Sprite
	
	Method New (x:Float, y:Float, z:Float, size:Float)
	
		Local tmp_mat:SpriteMaterial = New SpriteMaterial ()
		tmp_mat.ColorFactor = (Color.White + Color.LightGrey) * Rnd (0.25, 1.0)
		
		sprite = New Sprite (tmp_mat)
		
		sprite.Scale = New Vec3f (size, size, 1.0)
		
		sprite.Mode = SpriteMode.Fixed
		
		sprite.Move (x, y, z)
		
		sprite.Rotate (90.0, 0.0, 0.0)
		
	End
	
End
