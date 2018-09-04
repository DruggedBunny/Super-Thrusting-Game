
Class PhysicsTerrain ' WIP

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

		Field wall:Wall
		
	Public
		
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
		
		Method GenerateTerrain (seed:ULong, size:Int, terrain_height:Float, roughness:Float = 0.5, color0:Color, color1:Color)
		 
		 	terrain_data = New PlayfulJSTerrainMap (seed, size, roughness)
		 
				heightmap = terrain_data.RenderPixmap ()
		 
				If Not heightmap Then RuntimeError ("Failed to generate heightmap!")
		 
				heightmap.FlipY () ' 2D Y (increases downwards) translates to 3D Z (increases upwards)
			
			Local terrain_material:PbrMaterial = New PbrMaterial ()
		 
				terrain_material.ColorTexture = New Texture (CheckerPixmap (color0, color1), TextureFlags.None)
			
			height_box = New Boxf (-heightmap.Width * 0.5, 0.0, -heightmap.Height * 0.5, heightmap.Width * 0.5, terrain_height, heightmap.Height * 0.5)
			
			TerrainModel = Model.CreateTerrain (heightmap, height_box, New PbrMaterial (terrain_material))
			
				If Not TerrainModel Then Abort ("PhysicsTerrain.GenerateTerrain: Failed to create terrain model!")
			
				TerrainModel.Name = "Terrain [spawned at " + Time.Now () + "]"
						
			body		= TerrainModel.AddComponent <RigidBody> ()
	
				body.Mass = 0.0
		
				body.CollisionMask	= COLL_TERRAIN
				body.CollisionGroup	= TERRAIN_COLLIDES_WITH

			collider	= TerrainModel.AddComponent <TerrainCollider> ()

				collider.Heightmap	= heightmap
				collider.Bounds		= height_box

			wall = New Wall (height_box)
		 
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
		
		Method Destroy ()
			TerrainModel?.Destroy ()
			TerrainBody?.Destroy ()
			wall?.Destroy ()
		End
		
End

Class Wall

	Private
	
		Field bump:Sound
		Field bump_channel:Channel
		Field bump_channel_time:Int
		
		Field walls:Model []
		Field ceiling:Model
		
		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
				
	Public

	Method Destroy ()
		For Local wall:Model = Eachin walls
			wall.Destroy ()
		Next
		ceiling?.Destroy ()
	End
	
	Method New (height_box:Boxf)
	
		' Sound for bumping into invisible walls at outer edge of terrain/upper ceiling limit...
		
		bump = Sound.Load (ASSET_PREFIX_AUDIO + "wall_bump.ogg")

			If Not bump Then Abort ("PhysicsTerrain: Failed to load wall-bump audio!")

			bump_channel		= bump.Play (False)
			bump_channel.Paused	= True
			bump_channel_time	= Millisecs ()

		' Invisible walls around terrain...
		
		' Re-use collision box for all. (Technically results in possible collision failure at corners due to lack of overlap! Being lazy... )
		
		Local wall_box:Boxf = New Boxf (-height_box.Width * 0.5, -height_box.Height * 0.5, -2.0, height_box.Width * 0.5, height_box.Height * 2.5, 2.0)
		
		' Base wall model...
		
		Local wall_base:Model = Model.CreateBox (wall_box, 1, 1, 1, New PbrMaterial (Color.White))
		
			wall_base.Name = "Boundary wall base model"
		
		' Wall array...
		
		walls = New Model [4]
		
		For Local wall_instance:Int = 0 Until walls.Length
		
				' Copy base model...
				
				walls [wall_instance] = wall_base.Copy ()
				walls [wall_instance].Alpha = 0.0
				
				walls [wall_instance].Name = "Wall base copy [spawned at " + Time.Now () + "]"
				
				Select wall_instance
		
					Case 0	' Ahead
						walls [wall_instance].Move (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
		
					Case 1	' Behind
					
						walls [wall_instance].Move (0, height_box.Height * 0.5, -height_box.Depth * 0.5 - wall_box.Depth * 0.5)
			
					Case 2	' Left
					
						walls [wall_instance].Rotate (0, 90, 0)
						walls [wall_instance].Move (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
			
					Case 3	' Right
					
						walls [wall_instance].Rotate (0, -90, 0)
						walls [wall_instance].Move (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
			
				End
			
			' Collider...
			
			Local wall_collider:BoxCollider = walls [wall_instance].AddComponent <BoxCollider> ()
				
				wall_collider.Box = wall_box
		
			' Rigid body...
			
			Local wall_body:RigidBody = walls [wall_instance].AddComponent <RigidBody> ()
			
				wall_body.Mass = 0.0			' 0 = immoveable
				wall_body.Restitution = 1.0	' Bouncy!
				
				wall_body.CollisionMask	= COLL_WALL
				wall_body.CollisionGroup	= WALL_COLLIDES_WITH
			
				' Collision response function...
				
				wall_body.Collided += Lambda (other_body:RigidBody)
			
					' Play bounce sound only every 250 ms (avoids high-speed repetition when colliding)...
					
					If Millisecs () - bump_channel_time > 250
			
						' Un-pause channel (ie. play)...
						
						bump_channel.Paused = False
					
						' Start a new instance playing, but paused...
						
						bump_channel = bump.Play (False)
						bump_channel.Paused = True
						
						' Reset timer...
						
						bump_channel_time = Millisecs ()
						
					Endif
					
				End
		
		Next
		
		' Hide wall base model...
		
		wall_base.Destroy ()' = False ' Note that actual walls remain Visible = True, as Visible = False disables physics!
		
		' Ceiling, sits at 3 times total terrain height...
		
		' Better solution would be limiting rocket boost dependent on height, but would require testing (or actual mathematics) to ensure it remains wall height!
		
		' Travelling to ceiling feels a very long way, though, so anyone doing this is testing limits and deserves to be punished!
		
		Local ceiling_box:Boxf = New Boxf (-height_box.Width * 0.5, -2.0, -height_box.Depth * 0.5, height_box.Width * 0.5, 2.0, height_box.Depth * 0.5)
		
		ceiling = Model.CreateBox (ceiling_box, 1, 1, 1, New PbrMaterial (Color.White))
		
				ceiling.Alpha = 0.0
				ceiling.Move (0, height_box.Height * 3.0 + ceiling_box.Height * 0.5, 0.0)
			
				ceiling.Name = "Boundary ceiling [spawned at " + Time.Now () + "]"
				
		Local cc:BoxCollider = ceiling.AddComponent <BoxCollider> ()
				
				cc.Box = ceiling_box
		
		Local cb:RigidBody = ceiling.AddComponent <RigidBody> ()
		
			cb.Mass = 0.0			' 0 = immoveable
			cb.Restitution = 1.0	' Bouncy!
			
			cb.CollisionMask	= COLL_WALL
			cb.CollisionGroup	= WALL_COLLIDES_WITH
		
			' Collision response function...
			
			cb.Collided += Lambda (other_body:RigidBody)
		
				' Play bounce sound only every 250 ms (avoids high-speed repetition when colliding)...
				
				If Millisecs () - bump_channel_time > 250
		
					' Un-pause channel (ie. play)...
					
					bump_channel.Paused = False
				
					' Start a new instance playing, but paused...
					
					bump_channel = bump.Play (False)
					bump_channel.Paused = True
					
					' Reset timer...
					
					bump_channel_time = Millisecs ()
					
				Endif
				
			End
		
	End

End
