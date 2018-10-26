
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' Level creation and control, along with a small class to hold basic level
' data; the latter isn't really necessary, just simplified setup code.

Class Level

	Public
		
		Const FIXED_GEM_COUNT:Int = 8 ' Not sure if temp...

		Property Lock:PortalLock ()
			Return portal_lock
			Setter (lock:PortalLock)
				portal_lock = lock
		End
		
		Property Terrain:PhysicsTerrain ()
			Return terrain
			Setter (new_terrain:PhysicsTerrain)
				terrain = new_terrain
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
	
		Property Dummy:DummyOrb ()
			Return dummy_orb
			Setter (new_dummy:DummyOrb)
				dummy_orb = new_dummy
		End
		
		Property ExitPortal:Portal ()
			Return portal
			Setter (new_portal:Portal)
				portal = new_portal
		End
		
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

			terrain_seed				= seed
			
			LevelName				= ""

			SeedRnd (Millisecs ())
			
			Local color0:Color		= Color.Rnd ()
			Local color1:Color		= Color.Rnd ()
			
			' Terrain seed starts at 0 and increases with each level completion.
			' Six levels are set up by default; if terrain seed is < 6, use the
			' hard-coded level data from above...
			
			' (Level creation will use random terrain/colours after that.)
			
			If terrain_seed < levels.Length

				LevelName			= levels [terrain_seed].name
				color0				= levels [terrain_seed].color0
				color1				= levels [terrain_seed].color1
			
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
		
			terrain					= New PhysicsTerrain (terrain_seed, sides, 384, 0.5, color0, color1)

			sun.PointAt (terrain.TerrainModel)

			' -----------------------------------------------------------------
			' Create exit portal...
			' -----------------------------------------------------------------

			ExitPortal = New Portal (0.0, terrain.Height + 100.0, terrain.Depth * 0.25)

			gem_map = New GemMap (256.0)
			
		End

		Method SpawnLevel:Vec3f ()

			' Remove pads and gems from scene if they exist already (eg. on loading new level)...

			If pads Or gems Then DestroyPadsAndGems ()
			If pads Or gems Then DestroyPadsAndGems ()
			
			pads							= New List <Pad>
			gems	 						= New List <SpaceGem>
			
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
			
			spawn_x							= terrain.TerrainXFromHeightMap (pixmap_x)
			spawn_y							= terrain.TerrainYFromHeightMap (pixmap_x, pixmap_y) + player_pad_y_offset
			spawn_z							= terrain.TerrainZFromHeightMap (pixmap_y)
			
			Local pad:Pad					= Pad.Create (spawn_x, spawn_y, spawn_z, 8)
			
			pads.AddLast (pad)

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
			
			Local valid_position:Bool

			' -----------------------------------------------------------------
			' Set pad positions...
			' -----------------------------------------------------------------

			For Local spawning:Int = 0 Until FIXED_GEM_COUNT

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
					
					For Local existing:Pad = Eachin pads

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
				
				' EDIT: Or high enough number of gems, because of minimum distance requirement!
				
				' Got a valid position! Create pad here...
				
				Local pad:Pad = Pad.Create (pad_x, pad_y, pad_z)

					pads.AddLast (pad)
					
					gems.AddLast (SpawnSpaceGem (pad, Color.Rnd ()))
				
			Next

			' Sets number of gems initially spawned...
			
			spacegems_spawned = space_gem_count

			' -----------------------------------------------------------------
			' Portal lock...
			' -----------------------------------------------------------------

			pad_y_offset = 16

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
				
				For Local existing:Pad = Eachin pads

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

			Lock = PortalLock.Create (pad_x, pad_y, pad_z)
			
			' This returns the player's position. Bit naughty...
			
			Return New Vec3f (spawn_x, spawn_y, spawn_z)
		
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
			
			Return New Vec3f (spawn_x, spawn_y, spawn_z)
			
		End
		
		Method SpaceGemRemoved ()
			space_gems_collected = space_gems_collected + 1
		End
		
		Method SpaceGemAdded ()
			space_gem_count = space_gem_count + 1
		End

		Method Destroy ()
		
			sun.Destroy ()
			terrain.Destroy ()
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
		Field portal_lock:PortalLock
		
		Field dummy_orb:DummyOrb
		
		Field pads:List <Pad>
		Field gems:List <SpaceGem>
	
		Field gem_map:GemMap

		Method SpawnDummyOrb ()
			Dummy = New DummyOrb (spawn_x, spawn_y + 15, spawn_z)
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
			
			For Local p:Pad = Eachin pads
				p.PadModel.Destroy ()
			Next
			
			For Local sg:SpaceGem = Eachin gems
				sg.SpaceGemModel.Destroy ()
			Next
			
			pads.Clear ()
			gems.Clear ()
			
		End
		
		Method SpawnRocket (x:Float, y:Float, z:Float)
			Game.Controller.SpawnRocket (New Vec3f (x, y, z))
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
