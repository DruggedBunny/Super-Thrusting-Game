
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' A mischievously-named collection of border walls (plus ceiling)...

Class TrumpWall

	Public
	
		Method SetDebugAlpha (new_alpha:Float)
			
			For Local wall:Wall = Eachin walls
				wall.DebugAlpha = new_alpha
			Next

			ceiling.DebugAlpha	= new_alpha

		End
		
		Method Destroy ()
		
			For Local wall:Wall = Eachin walls
				wall.Destroy ()
			Next
			
			ceiling?.Destroy ()
			
		End
		
		Method New (height_box:Boxf)

			' Invisible walls around terrain...
			
			' Re-use collision box for all. (Technically results in POSSIBLE collision failure at corners due to lack of overlap! Being lazy... but never seen it happen!)
			
			Local wall_box:Boxf = New Boxf (-height_box.Width * 0.5, -height_box.Height * 0.5, -2.0, height_box.Width * 0.5, height_box.Height * 2.5, 2.0)
			
			' Position/rotation...
			
			Local pos:Vec3f
			Local yrot:Float
	
			' Wall array...
		
			walls = New Wall [4]
			
				pos			= New Vec3f (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
				yrot		= 0.0
				walls [0]	= Wall.Create (wall_box, pos, yrot, New PbrMaterial (Color.White), "Boundary wall, ahead")
	
				pos			= New Vec3f (0, height_box.Height * 0.5, -height_box.Depth * 0.5 - wall_box.Depth * 0.5)
				yrot		= 0.0
				walls [1]	= Wall.Create (wall_box, pos, yrot, New PbrMaterial (Color.White), "Boundary wall, behind")
	
				pos			= New Vec3f (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
				yrot		= 90.0
				walls [2]	= Wall.Create (wall_box, pos, yrot, New PbrMaterial (Color.White), "Boundary wall, left")
	
				pos			= New Vec3f (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
				yrot		= -90.0
				walls [3]	= Wall.Create (wall_box, pos, yrot, New PbrMaterial (Color.White), "Boundary wall, right")

			' Ceiling, sits at 3 times total terrain height...
			
			' Better solution would be limiting rocket boost dependent on height, but would require testing (or actual mathematics) to ensure it remains wall height!
			
			' Travelling to ceiling feels a very long way, though, so anyone doing this is testing limits and deserves to be punished!
	
			Local ceiling_box:Boxf = New Boxf (-height_box.Width * 0.5, -2.0, -height_box.Depth * 0.5, height_box.Width * 0.5, 2.0, height_box.Depth * 0.5)
			
				pos			= New Vec3f (0, height_box.Height * 3.0 + ceiling_box.Height * 0.5, 0.0)
				yrot		= 0.0
				
				ceiling		= Wall.Create (ceiling_box, pos, yrot, New PbrMaterial (Color.White), "Ceiling")

		End
	
	Private
	
		Field walls:Wall []
		Field ceiling:Wall
		
End
