
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class PhysicsTerrain ' WIP

	Public
		
		Property TerrainData:PlayfulJSTerrainMap ()
			Return terrain_data
		End
		
		Property TerrainBody:RigidBody ()
			Return body
		End
		
		Property TerrainModel:Model ()
			Return terrain
			Setter (new_model:Model)
				terrain = new_model
		End
		
		Property Width:Float ()
			Return height_box.Width
		End
		
		Property Height:Float ()
			Return height_box.Height
		End
		
		Property Depth:Float ()
			Return height_box.Depth
		End
		
		Method New (seed:ULong, size:Int, terrain_height:Float, roughness:Float = 0.5, color0:Color, color1:Color)
			GenerateTerrain (seed, size, terrain_height, roughness, color0, color1)
		End
		
		Method GenerateTerrain (seed:ULong, size:Int, terrain_height:Float, roughness:Float = 0.5, color0:Color, color1:Color)
		 
		 	terrain_data						= New PlayfulJSTerrainMap (seed, size, roughness)
		 
				heightmap						= terrain_data.RenderPixmap (10) ' Gaussian blur level - TODO: Add as parameter?
		 
				If Not heightmap Then RuntimeError ("Failed to generate heightmap!")
		 
				heightmap.FlipY () ' 2D Y (increases downwards) translates to 3D Z (increases upwards)
			
			Local terrain_material:PbrMaterial	= New PbrMaterial ()
		 
				terrain_material.ColorTexture	= New Texture (CheckerPixmap (64, 64, color0, color1), TextureFlags.None)
			
			height_box							= New Boxf (-heightmap.Width * 0.5, 0.0, -heightmap.Height * 0.5, heightmap.Width * 0.5, terrain_height, heightmap.Height * 0.5)

			TerrainModel						= Model.CreateTerrain (heightmap, height_box, New PbrMaterial (terrain_material))
			
				If Not TerrainModel Then Abort ("PhysicsTerrain.GenerateTerrain: Failed to create terrain model!")
			
				TerrainModel.Name				= "Terrain [spawned at " + Time.Now () + "]"
						
			body								= TerrainModel.AddComponent <RigidBody> ()
	
'				Game.PhysStack.Add (body)
	
				body.Mass						= 0.0
		
				body.CollisionMask				= COLL_TERRAIN
				body.CollisionGroup				= TERRAIN_COLLIDES_WITH

			collider							= TerrainModel.AddComponent <TerrainCollider> ()

				collider.Heightmap				= heightmap
				collider.Bounds					= height_box

			trump_wall							= New TrumpWall (height_box)
		 
'			 	wall.SetDebugAlpha (0.25)
		 	
		End
		
		Method TerrainXFromHeightMap:Float (pixmap_x:Float)
			Return TransformRange (pixmap_x, 0.0, heightmap.Width - 1, -Width * 0.5, Width * 0.5)
		End

		Method TerrainYFromHeightMap:Float (pixmap_x:Float, pixmap_y:Float)

			Local height:Float = heightmap.GetPixel (pixmap_x, (heightmap.Height - 1) - pixmap_y).R		' Red value from heightmap...

			Return TransformRange (height, 0.0, 1.0, 0.0, Height)

		End

		Method TerrainZFromHeightMap:Float (pixmap_y:Float)
			Return TransformRange (pixmap_y, heightmap.Height - 1, 0.0, -Depth * 0.5, Depth * 0.5)
		End

		Method TerrainYFromEntity:Float (entity:Entity)

			Local x:Float = entity.X
			Local z:Float = entity.Z
			
			x = TransformRange (x, -heightmap.Width * 0.5, heightmap.Width * 0.5, 0.0, heightmap.Width - 1)
			z = TransformRange (z, -heightmap.Height * 0.5, heightmap.Height * 0.5, 0.0, heightmap.Height - 1)
			
			Local height:Float = heightmap.GetPixel (x, z).R		' Red value from heightmap...

			' height_box.Height * 3.0 + ceiling_box.Height * 0.5 ' from TrumpWall
			
			Local upper:Float = (Height * 3.0) - 0.5 ' ceiling_box.Height = 1.0
			
			height = TransformRange (height, 0.0, 1.0, 0.0, Height)
			
			Return height

		End
		
		Method Destroy ()
		
			TerrainModel?.Destroy ()
			TerrainBody?.Destroy ()
			
			trump_wall?.Destroy ()
			
		End
		
	Private

		Field terrain:Model
		Field terrain_data:PlayfulJSTerrainMap

		Field pixels:Pixmap
		Field heightmap:Pixmap

		Field terrain_material:PbrMaterial
	
		Field width:Float
		Field height:Float
		
		Field height_box:Boxf
	
		Field collider:TerrainCollider		' Bullet physics collider
		Field body:RigidBody				' Bullet physics body

		Field trump_wall:TrumpWall
		
End
