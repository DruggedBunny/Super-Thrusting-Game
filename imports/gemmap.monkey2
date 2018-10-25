
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class GemMap

	Public
	
		Property GemMapImage:Image ()
			Return gem_map_image
		End

		Method New (size:Float, in_dot_size:Float = 4.0)
		
			gem_map_image	= New Image (size, size, PixelFormat.RGBA8, TextureFlags.Dynamic)
			gem_map_canvas	= New Canvas (gem_map_image)
			dot_size		= in_dot_size
			
		End
		
		Method Update ()
			
			gem_map_canvas.Clear (Color.Black)
			
			Local x_multi:Float	= gem_map_image.Width / Game.CurrentLevel.Terrain.TerrainData.Size'Width
			Local y_multi:Float	= gem_map_image.Height / Game.CurrentLevel.Terrain.TerrainData.Size
		
			Local offset:Float	= dot_size * 0.5
		
			Local half_terrain_size:Float = Game.CurrentLevel.Terrain.TerrainData.Size * 0.5
			
			gem_map_canvas.Clear (Color.Black)
			
			For Local sg:SpaceGem = Eachin Game.CurrentLevel.GemList
			
				If sg.Collected Then Continue

				gem_map_canvas.Color = Cast <PbrMaterial> (sg.SpaceGemModel.Material).ColorFactor
				
				Local ix:Float = TransformRange (sg.SpaceGemModel.X, -half_terrain_size, half_terrain_size, 0.0, gem_map_image.Width)
				Local iy:Float = TransformRange (sg.SpaceGemModel.Z, -half_terrain_size, half_terrain_size, gem_map_image.Height, 0.0)
				
				gem_map_canvas.DrawRect (ix - offset, iy - offset, dot_size, dot_size)
				
			Next
			
			If Game.CurrentLevel.ExitPortal.PortalState <> Portal.PORTAL_STATE_CLOSED

				Local ix:Float = TransformRange (Game.CurrentLevel.ExitPortal.Ring.X, -half_terrain_size, half_terrain_size, 0.0, gem_map_image.Width)
				Local iy:Float = TransformRange (Game.CurrentLevel.ExitPortal.Ring.Z, -half_terrain_size, half_terrain_size, gem_map_image.Height, 0.0)
					
				gem_map_canvas.Color = Color.White
				
				gem_map_canvas.DrawCircle (ix, iy, dot_size * 2.0)

				gem_map_canvas.Color = Color.Black

				gem_map_canvas.DrawCircle (ix, iy, dot_size)

			Endif
			
			If Game.CurrentLevel.Dummy

				Local ix:Float = TransformRange (Game.CurrentLevel.Dummy.DummyOrbModel.X, -half_terrain_size, half_terrain_size, 0.0, gem_map_image.Width)
				Local iy:Float = TransformRange (Game.CurrentLevel.Dummy.DummyOrbModel.Z, -half_terrain_size, half_terrain_size, gem_map_image.Height, 0.0)
				
				gem_map_canvas.Color = Color.HotPink * 0.75
				gem_map_canvas.DrawRect (ix - 4.0, iy - 4.0, 8.0, 8.0)

				gem_map_canvas.Color = Color.HotPink
				gem_map_canvas.DrawRect (ix - 2.0, iy - 2.0, 4.0, 4.0)

			Endif
			
			gem_map_canvas.Color = Color.White
			
			Local ix:Float = TransformRange (Game.Player.RocketModel.X, -half_terrain_size, half_terrain_size, 0.0, gem_map_image.Width)
			Local iy:Float = TransformRange (Game.Player.RocketModel.Z, -half_terrain_size, half_terrain_size, gem_map_image.Height, 0.0)
			
			' TODO: pre-calc offset
			gem_map_canvas.DrawRect (ix - offset, iy - offset, dot_size, dot_size)
				
			gem_map_canvas.Flush ()

		End
		
	Private

		Field dot_size:Float
		Field gem_map_image:Image
		Field gem_map_canvas:Canvas

End
