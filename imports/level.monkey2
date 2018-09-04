
Class LevelData

	Field name:String

	Field color0:Color
	Field color1:Color

	Method New (in_name:String, in_color0:Color, in_color1:Color)
		name = in_name
		color0 = in_color0
		color1 = in_color1
	End
	
End

Class Level

	Public
		
		Field pads:List <Pad>
		Field gems:List <SpaceGem>
		
		Property TerrainSeed:ULong ()
			Return terrain_seed
			Setter (new_seed:ULong)
				terrain_seed = new_seed
		End
		
'		Property Ground:Model ()
'			Return ground
'			Setter (new_ground:Model)
'				ground = new_ground
'		End
		
		Property Terrain:PhysicsTerrain ()
			Return terrain
			Setter (new_terrain:PhysicsTerrain)
				terrain = new_terrain
		End
		
		Property ExitPortal:Portal ()
			Return portal
		End
		
		Property SpaceGemCount:Int ()
			Return space_gem_count
		End
		
		Property SpaceGemsCollected:Int ()
			Return space_gems_collected
		End

		Property SpawnPointSet:Bool ()
			Return spawn_point_set
			Setter (set:Bool)
				spawn_point_set = set
		End
		
		Property SpawnX:Float ()
			Return spawn_x
			Setter (x:Float)
				spawn_x = x
		End
		
		Property SpawnY:Float ()
			Return spawn_y
			Setter (y:Float)
				spawn_y = y
		End
		
		Property SpawnZ:Float ()
			Return spawn_z
			Setter (z:Float)
				spawn_z = z
		End
		
		Method New (level:String, seed:ULong, sides:Float)

			If Not some_levels.Length

				some_levels = New LevelData [6]

				some_levels[0] =	New LevelData ("Earthly",
									New Color (0.0, 0.498, 0.0),
									New Color (0.0275, 0.357, 0.176))

				some_levels[1] =	New LevelData ("Desert",
									((Color.Yellow * 0.5) + (Color.Brown * 0.5) + Color.Orange) * 0.33,
									((Color.Yellow * 0.8) + Color.Orange * 0.75) * 0.5)

				some_levels[2] =	New LevelData ("Martian Hell",
									New Color (1.0, 0.2, 0.2),
									New Color (0.75, 0.2, 0.2))

				some_levels[3] =	New LevelData ("Winterlong",
									New Color (0.95, 0.95, 1.0),
									New Color (0.75, 0.75, 0.95))

				some_levels[4] =	New LevelData ("The New Blue",
									New Color (0.25, 0.5, 1.0),
									New Color (0.5, 0.8, 1.0))

				some_levels[5] =	New LevelData ("Chess World",
									New Color (0.2, 0.2, 0.2 ),
									New Color (0.8, 0.8, 0.8))

			Endif

			If pads Or gems Then DestroyPadsAndGems ()
			
			pads = New List <Pad>
			gems = New List <SpaceGem>
			
			TerrainSeed = seed
			
			LevelFile = level
			
			' Read whole level file into one string...
			
			'file_data = LoadString (ASSET_PREFIX_LEVEL + level, True) ' Convert to Unix ~n newline
	
			' Get level name...
			
			LevelName = ""

			SeedRnd (Millisecs ())
			
			Local color0:Color = Color.Rnd ()
			Local color1:Color = Color.Rnd ()
			
			If some_levels
			
				If TerrainSeed < some_levels.Length

					LevelName	= some_levels [TerrainSeed].name

					color0		= some_levels [TerrainSeed].color0
					color1		= some_levels [TerrainSeed].color1

				Endif
				
			Endif
			
			If Not LevelName
				LevelName = "randomly-generated level"
			Endif
			
			' Get sun position and range...
			
			Local sun_x:Float		= 256.0'Cast <Float> (ReadLevelData (file_data, "SUN_X"))
			Local sun_y:Float		= 1024' Cast <Float> (ReadLevelData (file_data, "SUN_Y"))
			Local sun_z:Float		= 512'Cast <Float> (ReadLevelData (file_data, "SUN_Z"))

			Local sun_range:Float	= 2500.0'Cast <Float> (ReadLevelData (file_data, "SUN_RANGE"))

			sun						= New Light
	
				sun.Name = "Sun [spawned at " + Time.Now () + "]"
			
				sun.CastsShadow		= True
				sun.Range			= sun_range
				sun.Color			= Color.White
				
				sun.Move (sun_x, sun_y, sun_z)
		
			' TODO: New PhysicsTerrain should probably incorporate PhysicsTerrain.LoadTerrain...
			
			terrain					= New PhysicsTerrain ()
			
			' Load terrain...
			
			terrain.GenerateTerrain (TerrainSeed, sides, 384, 0.5, color0, color1)

			sun.PointAt (terrain.TerrainModel)
	
			portal = New Portal (0.0, terrain.Height + 100.0, 50.0)
			'portal.Hide ()

			SpawnPointSet = False

		End

		Method SpawnSpaceGem:SpaceGem (pad:Pad, color:Color)
			
			' TODO: Move model creation into SpaceGem!!
			
			If color <> Null

				Local size:Float = pad.PadModel.Mesh.Bounds.Width * 0.5
				
				Local box:Boxf = New Boxf (-size * 0.5, -size * 0.5, -size * 0.5, size * 0.5, size * 0.5, size * 0.5)
				
				Local sg_model:Model = Model.CreateBox (box, 1, 1, 1, New PbrMaterial (color))
				Local sg:SpaceGem = SpaceGem.Create (sg_model, box, pad.PadModel.X, pad.PadModel.Y, pad.PadModel.Z)
				
				sg_model.Name = "SpaceGem [spawned at " + Time.Now () + "]"
				
				Return sg
				
			Endif
		
			Return Null

		End
		
		Method SpawnRocket (x:Float, y:Float, z:Float)
			Game.SpawnRocket (New Vec3f (x, y, z))
		End
		
		Method SpawnLevel:Vec3f () ' SpawnLevelContents?

			' Get level data filename...
			
			' LEVEL DATA is gem/player start positions
			
			' TEMP
			
			Local level_data_png:String = "asset::levels\test_level\level_data.png"'ReadLevelData (file_data, "LEVEL_DATA")
			
			Local png:Pixmap = Pixmap.Load (level_data_png)
			
			If Not png Then Abort ("SpawnLevel: No level PNG!")
			
			Local pad_y_offset:Float		= 4.0
			Local player_pad_y_offset:Float	= 20.0
			
			For Local pixmap_y:Int = 0 Until png.Height
			
				For Local pixmap_x:Int = 0 Until png.Width
				
					Local argb:Color = png.GetPixel (pixmap_x, pixmap_y)
					
					If argb.R Or argb.G Or argb.B
						
						' Any non-black colour...
						
						If argb = Color.Red
						
							' Red pixel?

							' -------------------
							' Player spawn point
							' -------------------
							
							' Check for 2x2 square. This will be player spawn point if so...
							
							If png.GetPixel (pixmap_x + 1, pixmap_y) = Color.Red And
								png.GetPixel (pixmap_x, pixmap_y + 1) = Color.Red And
									png.GetPixel (pixmap_x + 1, pixmap_y + 1) = Color.Red
							
								' Above If line ends here!
							
								If Not SpawnPointSet
								
									SpawnX = terrain.TerrainXFromHeightMap (pixmap_x)
									SpawnY = terrain.TerrainYFromHeightMap (pixmap_x, pixmap_y, True) + player_pad_y_offset
									SpawnZ = terrain.TerrainZFromHeightMap (pixmap_y)
									
									Local pad:Pad = New Pad (SpawnX, SpawnY, SpawnZ, 8)
									
										pads.AddLast (pad)
									
									SpawnPointSet = True
									
								Endif

							Else

								' Red pixel, not start of 2x2 square. Check if no others left, up, right, down and spawn red gem...
								
								If LonePixel (pixmap_x, pixmap_y, argb, png)
								
									Local pad_x:Float = terrain.TerrainXFromHeightMap (pixmap_x)
									Local pad_y:Float = terrain.TerrainYFromHeightMap (pixmap_x, pixmap_y) + pad_y_offset
									Local pad_z:Float = terrain.TerrainZFromHeightMap (pixmap_y)
										
									Local pad:Pad = New Pad (pad_x, pad_y, pad_z)

										pads.AddLast (pad)
										gems.AddLast (SpawnSpaceGem (pad, argb))
										
								Endif
								
							Endif
						
						Else
						
							' Non-red pixel...
							
							Local pad_x:Float = terrain.TerrainXFromHeightMap (pixmap_x)
							Local pad_y:Float = terrain.TerrainYFromHeightMap (pixmap_x, pixmap_y) + pad_y_offset
							Local pad_z:Float = terrain.TerrainZFromHeightMap (pixmap_y)
			
							Local pad:Pad = New Pad (pad_x, pad_y, pad_z)

								pads.AddLast (pad)
								gems.AddLast (SpawnSpaceGem (pad, argb))
							
						Endif
						
					Endif
					
				Next
				
			Next
			
			spacegems_spawned = SpaceGemCount
		
			Assert (SpawnPointSet, "Level.SpawnLevel: Rocket spawn point not set in level data!")
			
			Return New Vec3f (SpawnX, SpawnY, SpawnZ)
		
		End

		Method LonePixel:Bool (x:Int, y:Int, argb:Color, map:Pixmap)
		
			Local pix:Color = map.GetPixel (x, y)
			
			If pix = argb
				
				If map.GetPixel (x - 1, y) = pix Or
					map.GetPixel (x, y - 1) = pix Or
						map.GetPixel (x + 1, y) = pix Or
							map.GetPixel (x, y + 1) = pix
					
								Return False

				Endif
				
			Endif
			
			Return True

		End

		Method OrbCollected:Bool ()
		
			If Not orb_collected
			
				If Not Game.Player.CurrentOrb
			
					' TODO: Spawn with player if died but already collected? Just set dummy invisible?
				
					Game.Player.CurrentOrb = New Orb (Game.Player, 10.0, 8.0)
					orb_collected = True
					
				Endif
				
			Endif
			
			Return orb_collected
			
		End
		
		Method Complete:Bool ()
space_gems_collected = spacegems_spawned ' TEMP!!!
			
			If space_gems_collected = spacegems_spawned
				
				' TODO: Spawn collider above dummy orb, triggers portal (tweak OrbCollected to accommodate)...
				
				If OrbCollected () And portal.PortalState = Portal.PORTAL_STATE_CLOSED
					portal.PortalState = Portal.PORTAL_STATE_OPENING' If portal.Hidden Then Print "Yup!"; portal.Show ()
				Endif
				
				If ExitPortal.Complete ()
					portal.PortalState = Portal.PORTAL_STATE_CLOSING
					Game.GameState.SetCurrentState (States.LevelTween) ' TODO: See Case Portal.PORTAL_STATE_CLOSING
					Return True
				Endif
				
			Endif
			
			Return False
			
		End
		
		Method Reset:Vec3f ()
	
			PhysicsTri.Clear ()
			
			Game.MainCamera.Reset ()
			
			GameState.SetCurrentState (States.PlayStarting)
			
			Return New Vec3f (SpawnX, SpawnY, SpawnZ)
			
		End
		
		Method SpaceGemRemoved ()
			space_gems_collected = space_gems_collected + 1
		End
		
		Method SpaceGemAdded ()
			space_gem_count = space_gem_count + 1
		End

		Function GetLevelName:String ()
			Return LevelName
		End

		Method Destroy ()
		
			orb_collected = False

			Terrain.Destroy ()
			
			DestroyPadsAndGems ()
			
			sun.Destroy ()
			
		End
		
		Method DestroyPadsAndGems ()
			
			For Local p:Pad = Eachin pads
			
				' TODO: Move to Pad.Destroy ()!
				p.PadModel.Destroy ()
				p.PadBody.Destroy ()
				
			Next
			
			For Local sg:SpaceGem = Eachin gems
			
				' TODO: Move to SpaceGem.Destroy ()!
				sg.GetSpaceGemModel ().Destroy ()
				sg.GetSpaceGemBody ().Destroy ()
				
			Next
			
		End
		
	'Private

		'Const ASSET_PREFIX_LEVEL:String = "asset::levels/"
		
		Global LevelFile:String
		Global LevelName:String
		
		Field space_gem_count:Int
		Field space_gems_collected:Int ' TEMP!
		Field spacegems_spawned:Int
		
		Field spawn_point_set:Bool
		
		Field spawn_x:Float
		Field spawn_y:Float
		Field spawn_z:Float
		
		Field sun:Light

		Field terrain_seed:ULong
	
		Field terrain:PhysicsTerrain
		
		Field ground_pixels:Pixmap
	
		Field heightmap:Pixmap
		Field terrain_material:PbrMaterial

		Field portal:Portal
		
		Field orb_collected:Bool
		
		Field file_data:String

		Field some_levels:LevelData []
		
End
