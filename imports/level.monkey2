
Class Level

	Public
		
		Const FIXED_GEM_COUNT:Int = 10 ' Not sure if temp...

		Property CurrentGemMap:GemMap ()
			Return gem_map
		End
		
		Property GemList:List <SpaceGem> ()
			Return gems
			Setter (new_list:List <SpaceGem>)
				gems = new_list
		End
		
		Property LevelName:String ()
			Return level_name
			Setter (new_name:String)
				level_name = new_name
		End
		
		Method New (seed:ULong, sides:Float)

			If Not levels.Length

				' -------------------------------------------------------------
				' Create level data if not already done (only happens once)...
				' -------------------------------------------------------------
				
				' NB. Hard-coded here, should really be read in from external files...
				
				' LevelData class is defined in this file, below Level...
				
				levels		=	New LevelData [6]

				levels[0]	=	New LevelData ("Earthly",			' Display name
								New Color (0.0, 0.498, 0.0),		' Terrain color 0
								New Color (0.0275, 0.357, 0.176))	' Terrain color 1

				levels[1]	=	New LevelData ("Desert",
								((Color.Yellow * 0.5) + (Color.Brown * 0.5) + Color.Orange) * 0.33,
								((Color.Yellow * 0.8) + Color.Orange * 0.75) * 0.5)

				levels[2]	=	New LevelData ("Martian Hell",
								New Color (1.0, 0.2, 0.2),
								New Color (0.75, 0.2, 0.2))

				levels[3]	=	New LevelData ("Winterlong",
								New Color (0.95, 0.95, 1.0),
								New Color (0.75, 0.75, 0.95))

				levels[4]	=	New LevelData ("I'll Be Blue",
								New Color (0.25, 0.5, 1.0),
								New Color (0.5, 0.8, 1.0))

				levels[5]	=	New LevelData ("Checkmate!",
								New Color (0.2, 0.2, 0.2 ),
								New Color (0.8, 0.8, 0.8))

			Endif

			' -----------------------------------------------------------------
			' Init level data...
			' -----------------------------------------------------------------

			TerrainSeed				= seed
			
			LevelName				= ""

			SeedRnd (Millisecs ())
			
			Local color0:Color		= Color.Rnd ()
			Local color1:Color		= Color.Rnd ()
			
			' Terrain seed starts at 0 and increases with each level completion.
			' Six levels are set up by default; if terrain seed is < 6, use the
			' hard-coded level data from above...
			
			' (Level creation will use random terrain/colours after that.)
			
			If TerrainSeed < levels.Length

				LevelName			= levels [TerrainSeed].name
				color0				= levels [TerrainSeed].color0
				color1				= levels [TerrainSeed].color1
			
			Endif
			
			' -----------------------------------------------------------------
			' Set up sun...
			' -----------------------------------------------------------------
			
			Local sun_x:Float		= 256.0
			Local sun_y:Float		= 1024.0
			Local sun_z:Float		= 512.0

			Local sun_range:Float	= 2500.0

			sun						= New Light
	
				sun.Name = "Sun [spawned at " + Time.Now () + "]"
			
				sun.CastsShadow		= True
				sun.Range			= sun_range
				sun.Color			= Color.White
				
				sun.Move (sun_x, sun_y, sun_z)

			' -----------------------------------------------------------------
			' Generate a new terrain...
			' -----------------------------------------------------------------
		
			terrain					= New PhysicsTerrain (TerrainSeed, sides, 384, 0.5, color0, color1)

			sun.PointAt (terrain.TerrainModel)

			' -----------------------------------------------------------------
			' Create exit portal...
			' -----------------------------------------------------------------

			ExitPortal = New Portal (0.0, terrain.Height + 100.0, terrain.Depth * 0.25)

			gem_map = New GemMap (256.0)
			
		End

		Method SpawnLevel:Vec3f ()

			' Remove pads and gems from scene if they exist already (eg. on loading new level)...

			If PadList Or GemList Then DestroyPadsAndGems ()
			
			PadList							= New List <Pad>
			GemList 						= New List <SpaceGem>
			
			Local pad_y_offset:Float		= 4.0
			Local player_pad_y_offset:Float	= 20.0
			
			' Used to obtain positions from heightmap (Pixmap)...
			
			Local pixmap_x:Float
			Local pixmap_y:Float
			
			' Start position is middle of terrain...
			
			pixmap_x						= terrain.Width * 0.5
			pixmap_y						= terrain.Depth * 0.5
		
			' -----------------------------------------------------------------
			' Player pad...
			' -----------------------------------------------------------------
			
			' Player pad position is height at centre of map, plus y offset...
			
			SpawnX							= terrain.TerrainXFromHeightMap (pixmap_x)
			SpawnY							= terrain.TerrainYFromHeightMap (pixmap_x, pixmap_y) + player_pad_y_offset
			SpawnZ							= terrain.TerrainZFromHeightMap (pixmap_y)
			
			Local pad:Pad					= Pad.Create (SpawnX, SpawnY, SpawnZ, 8)
			
			PadList.AddLast (pad)

			' -----------------------------------------------------------------
			' Other pads...
			' -----------------------------------------------------------------

			Local pad_x:Float
			Local pad_y:Float
			Local pad_z:Float

			' Ensure same layout for each terrain seed value...
			
			If terrain_seed = 0
				SeedRnd (1000)	' Seed = 0 makes for a load of green gems on a green backdrop! 1000 looks OK...
			Else
				SeedRnd (terrain_seed)
			Endif
			
			' -----------------------------------------------------------------
			' Set pad positions...
			' -----------------------------------------------------------------

			For Local spawning:Int = 0 Until FIXED_GEM_COUNT

				Local valid_position:Bool

				Repeat
				
					' Proposed position: Random x/y, with padding of 10 at borders...
					
					pixmap_x = Rnd (10.0, (terrain.Width - 1) - 10.0)
					pixmap_y = Rnd (10.0, (terrain.Depth - 1) - 10.0)
					
					' Start by assuming valid position...
					
					valid_position = True
				
					pad_x = terrain.TerrainXFromHeightMap (pixmap_x)
					pad_y = terrain.TerrainYFromHeightMap (pixmap_x, pixmap_y) + pad_y_offset
					pad_z = terrain.TerrainZFromHeightMap (pixmap_y)
	
					' Check position against all spawned pads...
					
					For Local existing:Pad = Eachin PadList

						' New position as 3D vector...
						
						Local new_position:Vec3f = New Vec3f (pad_x, pad_y, pad_z)

						' Compare against position of existing gems in level...
						
						If new_position.Distance (existing.PadModel.Position) < 50.0

							' Too close to an existing gem... exit pad comparison loop and go back around Repeat/Until loop!

							valid_position = False
							Exit

						Endif

					Next

				Until valid_position
				
				' NB. ^^ Could cause infinite loop with small enough terrain or REALLY unlucky Rnd results!
				
				' Got a valid position! Create pad here...
				
				
				Local pad:Pad = Pad.Create (pad_x, pad_y, pad_z)

					PadList.AddLast (pad)
					
					GemList.AddLast (SpawnSpaceGem (pad, Color.Rnd ()))
				

			Next

			' Sets number of gems initially spawned...
			
			spacegems_spawned = SpaceGemCount
		
			' This returns the player's position. Bit naughty...
			
			Return New Vec3f (SpawnX, SpawnY, SpawnZ)
		
		End

		Method Update:Bool ()

			If TMP_LEVEL_COMPLETE Then space_gems_collected = spacegems_spawned ' TEMP!!!
			
			If space_gems_collected = spacegems_spawned
				
				' Respawn dummy orb if needed...
				
				If Not Dummy						' Dummy orb doesn't exist
					If Not Game.Player.CurrentOrb	' Player isn't carrying an orb already
						SpawnDummyOrb ()			' OK, spawn!
					Endif
				Endif

			Endif
			
			Return False
			
		End
		
		Method Reset:Vec3f ()
	
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

		Method Destroy ()
		
			sun.Destroy ()
			Terrain.Destroy ()
			ExitPortal.Destroy ()

			DestroyPadsAndGems ()
			
		End
		
		' Remove from list, otherwise we crash in DestroyPadsAndGems if a SpaceGem has been destroyed...
		
		Method RemoveSpaceGem (sg:SpaceGem)
			If sg Then GemList.Remove (sg)
		End
		
	Private
		
		Field levels:LevelData []
		Field level_name:String
		
		Field terrain_seed:ULong
		Field terrain:PhysicsTerrain

		Field space_gem_count:Int
		Field space_gems_collected:Int
		Field spacegems_spawned:Int
		
		Field spawn_x:Float
		Field spawn_y:Float
		Field spawn_z:Float
		
		Field sun:Light
		Field portal:Portal
		Field dummy_orb:DummyOrb
		
		Field pads:List <Pad>
		Field gems:List <SpaceGem>
	
		Field gem_map:GemMap

		Method SpawnDummyOrb ()
			Dummy = New DummyOrb (SpawnX, SpawnY + 15, SpawnZ)
		End
		
		Method SpawnSpaceGem:SpaceGem (pad:Pad, color:Color)
			
			If color <> Null

				Local size:Float	= pad.PadModel.Mesh.Bounds.Width * 0.5

				Local box:Boxf		=  New Boxf (-size * 0.5, -size * 0.5, -size * 0.5, size * 0.5, size * 0.5, size * 0.5)
				
				Return SpaceGem.Create (pad.PadModel, color)
				
			Endif
		
			Return Null

		End
		
		Method DestroyPadsAndGems ()
			
			For Local p:Pad = Eachin PadList
				p.PadModel.Destroy ()
			Next
			
			For Local sg:SpaceGem = Eachin GemList
				sg.SpaceGemModel.Destroy ()
			Next
			
			PadList.Clear ()
			GemList.Clear ()
			
		End
		
		Method SpawnRocket (x:Float, y:Float, z:Float)
			Game.SpawnRocket (New Vec3f (x, y, z))
		End

' TODO: Why are these properties if Private??

		Property PadList:List <Pad> ()
			Return pads
			Setter (new_list:List <Pad>)
				pads = new_list
		End
		
		Property Dummy:DummyOrb ()
			Return dummy_orb
			Setter (new_dummy:DummyOrb)
				dummy_orb = new_dummy
		End
		
		Property TerrainSeed:ULong ()
			Return terrain_seed
			Setter (new_seed:ULong)
				terrain_seed = new_seed
		End
		
		Property Terrain:PhysicsTerrain ()
			Return terrain
			Setter (new_terrain:PhysicsTerrain)
				terrain = new_terrain
		End
		
		Property ExitPortal:Portal ()
			Return portal
			Setter (new_portal:Portal)
				portal = new_portal
		End
		
		Property SpaceGemCount:Int ()
			Return space_gem_count
		End
		
		Property SpaceGemsCollected:Int ()
			Return space_gems_collected
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
				
End

Class LevelData

	Private
	
		Field name:String
	
		Field color0:Color
		Field color1:Color
	
		Method New (in_name:String, in_color0:Color, in_color1:Color)
			name = in_name
			color0 = in_color0
			color1 = in_color1
		End
	
End
