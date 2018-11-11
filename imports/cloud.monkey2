
' WIP WIP WIP!

Class Cloud

	' Quick hack...
	
	Public
	
		Field z_move:Float
		
		Method New (x:Float, y:Float, z:Float, size:Float)
		
			If Not CloudList
				CloudList = New List <Cloud>
			Endif
			
			If Not CloudPivot
				CloudPivot	= New Pivot ()
				Update ()
			Endif
			
			'If Not CloudMaterial
			'	CloudMaterial					= New SpriteMaterial ()
			'	CloudMaterial.ColorFactor		= (Color.White + Color.LightGrey) * Rnd (0.25, 1.0)
			'Endif
			
			' Needs mojo3d bugfix for sprite materials (should be able to set ColorFactor per-sprite)...
			
			Local tmp_mat:SpriteMaterial		= New SpriteMaterial ()
			tmp_mat.ColorFactor					= (Color.White + Color.LightGrey) * Rnd (0.25, 1.0)
			
			sprite								= New Sprite (tmp_mat, CloudPivot)
			
				sprite.Scale					= New Vec3f (size, size, 1.0)
			
				sprite.Mode						= SpriteMode.Fixed
			
				sprite.Move (x, y, z)
			
				sprite.Rotate (90.0, Rnd (-10.0, 10.0), 0.0)
			
			z_move = Rnd (-10.0, 10.0)
			
			CloudList.Add (Self)
			
		End
		
		Function Update ()
			
			' Clouds are always same distance above player; called from GameController...
			
			CloudPivot.SetPosition (Game.Player.RocketModel.Position)
			
'			For Local cloud:Cloud = Eachin CloudList

'				cloud.sprite.Move (0.0, cloud.z_move, 0.0)

' Nope!				
'				cloud.sprite.Alpha = TransformRange (Game.MainCamera.Camera3D.Position.Distance (cloud.sprite.Position), 0.0, Game.TerrainSize * 4.0, 1.0, 0.0)
				
'			Next
			
		End
		
	Private
	
		Global CloudPivot:Pivot
		Global CloudMaterial:SpriteMaterial
		Global CloudList:List <Cloud>
		
		Field sprite:Sprite
		
End
